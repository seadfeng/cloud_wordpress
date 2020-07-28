require 'rest-client'
module Wordpress
    module Core
        module Helpers
            class CloudflareApi
                attr_reader :cloudflare, :client, :rootdomain, :headers, :list_zone, :cdn_zone_id, :total_count, :remaining, :name, :type, :result_id

                def initialize( cloudflare, rootdomain = nil )
                    @cloudflare = cloudflare 
                    @rootdomain = rootdomain
                    @headers = {
                        'X-Auth-Email' => cloudflare.api_user,
                        'X-Auth-Key' => cloudflare.api_token,
                        :content_type => :json, 
                        :accept => :json
                    } 
                end     

                def get_user_id
                    @client = rest_client( user_url , 'get', @headers )  
                    if @client && @client.body
                        body = JSON.parse(@client.body)
                        if body["success"] 
                            user_id = body["result"]["id"]  
                        end   
                    end
                end

                # #name = www , content = demo.com
                def create_or_update_dns_cname(name, content, proxied = false)
                    @type = "CNAME"
                    @name = name
                    if can_update?
                        if get_result_id
                            update_dns(name, content, proxied )
                        else 
                            create_dns(name, content, proxied )
                        end 
                    end 
                end

                #name = www , content = 127.0.0.1
                def create_or_update_dns_a(name, content, proxied = false)
                    @type = "A"
                    @name = name
                    if can_update? 
                        if get_result_id
                            update_dns(name, content, proxied )
                        else 
                            create_dns(name, content, proxied )
                        end 
                    end 
                end

                private

                def create_dns(name, content, proxied = false)
                    data =  {
                        :type => type ,
                        :name => name , 
                        :content => content , 
                        :ttl => 120,  
                        :priority => 10,
                        :proxied => proxied 
                    }
                    @client = rest_client(dns_url, "post", data.to_json, @headers )
                end

                def update_dns(name, content, proxied = false)
                    data =  {
                        :type => type ,
                        :name => name , 
                        :content => content , 
                        :ttl => 120,  
                        :priority => 10,
                        :proxied => proxied 
                    }
                    @client = rest_client(update_dns_url, "put", data.to_json, @headers  )
                end

                def max_size
                    3500
                end

                def can_update? 
                    get_cdn_zone_id && check_total_count   
                end

                def check_total_count 
                    @list_zone = rest_client(dns_url, "get", @headers )
                    if @list_zone && @list_zone.code == 200
                        body = JSON.parse(@list_zone.body)  
                        if body["success"]
                            @total_count = body["result_info"]["total_count"].to_i
                            @remaining = max_size - @total_count 
                            if remaining > 0
                                true
                            else
                                false
                            end 
                        else
                            raise "List zone failure"
                        end
                    else
                        raise "Http status: #{zone.code} -> check_total_count"
                    end 
                end

                def get_result_id
                    result = rest_client(list_dns_url, "get"  )
                    if result && result.code == 200
                        body = JSON.parse(result.body)  
                       if body["success"] &&  body["result"][0]
                            @result_id = body["result"][0]["id"] 
                       else
                            nil
                       end
                    else
                        raise "Http status: #{result.code} -> get_result_id"
                    end
                end

                def get_cdn_zone_id 
                    zone = rest_client(list_zone_url, "get" )
                    if zone && zone.code == 200
                        body = JSON.parse(zone.body)  
                       if body["success"] &&  body["result"][0]
                            @cdn_zone_id = body["result"][0]["id"] 
                       else
                            nil
                       end
                    else
                        raise "Http status: #{zone.code} -> get_cdn_zone_id"
                    end
                end

                def api_v4
                    "https://api.cloudflare.com/client/v4"
                end

                def list_zone_url
                    "#{api_v4}/zones/?name=#{rootdomain}&status=active&page=1&per_page=20&order=status&direction=desc&match=all"
                end 

                def user_url
                    "#{api_v4}/user"
                end
 
                def list_dns_url 
                    "#{dns_url}?type=#{type}&name=#{name}&match=all"
                end 

                def dns_url 
                    "#{api_v4}/zones/#{cdn_zone_id}/dns_records"
                end 
                
                def update_dns_url
                    "#{dns_url}/#{result_id}"
                end

                def rest_client( url, method, *options )  
                    options = options.first || {}   
                    begin
                      if method === "post"
                        RestClient.post url, options, @headers 
                      elsif method === "put"
                        RestClient.put url, options, @headers 
                      else 
                        RestClient.get url, @headers 
                      end
                    rescue RestClient::ExceptionWithResponse  => e
                        case e.http_code 
                        when 301, 302, 307 
                          e.response.follow_redirection
                        else 
                          raise
                        end
                    end
                end 
            end
        end
    end
end