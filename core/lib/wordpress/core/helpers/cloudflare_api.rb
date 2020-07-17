require 'rest-client'
module Wordpress
    module Core
        module Helpers
            class CloudflareApi
                attr_reader :cloudflare, :client, :rootdomain, :headers, :list_zone, :cdn_zone_id, :total_count, :remaining

                def initialize( cloudflare, rootdomain )
                    @cloudflare = cloudflare 
                    @rootdomain = rootdomain
                    @headers = {
                        'X-Auth-Email' => cloudflare.api_user,
                        'X-Auth-Key' => cloudflare.api_token,
                        :content_type => :json, 
                        :accept => :json
                    } 
                end     

                # #name = www , content = demo.com
                def create_dns_cname(name, content, proxied = false)
                    if can_create?
                        data =  {
                            :type => "CNAME" ,
                            :name => name , 
                            :content => content , 
                            :ttl => 120, 
                            :priority => 10 , 
                            :proxied => proxied 
                        }
                        @client = rest_client(dns_url, "post", data, @headers )
                    else
                        nil
                    end 
                end

                #name = www , content = 127.0.0.1
                def create_dns_a(name, content, proxied = false)
                    if can_create?
                        data =  {
                            :type => "A" ,
                            :name => name , 
                            :content => content , 
                            :ttl => 120,  
                            :proxied => proxied 
                        }
                        @client = rest_client(dns_url, "post", data, @headers )
                    else
                        nil
                    end 
                end

                private

                def max_size
                    3500
                end

                def can_create? 
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

                def get_cdn_zone_id 
                    zone = rest_client(list_zone_url, "get",  @headers )
                    if zone && zone.code == 200
                        body = JSON.parse(zone.body)  
                       if body["success"] 
                            @cdn_zone_id = obj["result"][0]["id"] 
                       else
                        raise "Get cdn zone id failure"
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

                def dns_url 
                    "#{api_v4}/zones/#{cdn_zone_id}/dns_records"
                end 

                def rest_client( url, method, *options ) 
                    options = options.first || {} 
                    begin
                      if method === "get"
                        RestClient.get url, options 
                      else
                        RestClient.post url, options 
                      end
                    rescue RestClient::ExceptionWithResponse  => e
                        case err.http_code 
                        when 301, 302, 307 
                          err.response.follow_redirection
                        else 
                          raise
                        end
                    end
                end 
            end
        end
    end
end