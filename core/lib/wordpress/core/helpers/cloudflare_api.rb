require 'rest-client'
module Wordpress
    module Core
        module Helpers
            class CloudflareApi
                attr_reader :cloudflare, :client, :headers,  :zone_id, :total_count, :remaining, :dns_id

                def initialize( *cloudflare )
                    cloudflare = cloudflare.first  
                    if (cloudflare.is_a?(Cloudflare)  || cloudflare.is_a?(Wordpress::Cloudflare)  )
                        @zone_id =  cloudflare.zone_id 
                        @cloudflare = {
                            api_user: cloudflare.api_user,
                            api_token: cloudflare.api_token,
                        } 
                    else
                        @cloudflare = cloudflare
                    end 

                    @headers = {
                        'X-Auth-Email' => @cloudflare[:api_user],
                        'X-Auth-Key' => @cloudflare[:api_token],
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

                def get_account_id
                    @client = rest_client( accounts_url , 'get', @headers )  
                    if @client && @client.body
                        body = JSON.parse(@client.body)
                        if body["success"] 
                            account_id = body["result"][0]["id"]  
                        end   
                    end
                end

                # #name = www , content = demo.com
                def create_or_update_dns_cname(name, content, proxied = false)
                    raise I18n.t('active_admin.cloudflare.zone_id.blank', default: "Please set cloudflare domain's zone id. object.set_zone_id('7c5dae5552338874e5053f2534d2767a'). https://api.cloudflare.com/#zone-properties") if  zone_id.blank?
                    type = "CNAME" 
                    if can_update?
                        if get_dns_id(type, name)
                            update_dns(type, name, content, proxied )
                        else 
                            create_dns(type, name, content, proxied )
                        end 
                    end 
                end

                def find_or_create_zone(domain,account_id)
                    zone =  find_zone(domain)
                    return zone if zone 
                    create_zone(domain,account_id)
                end

                def create_zone(domain,account_id)
                    data = {
                        :name => domain,
                        :account => {
                            :id => account_id
                         },
                        :jump_start => true,
                        :type => "full"
                    }
                    @client = rest_client(zone_url, "post", data.to_json, @headers )
                    if @client && @client.code == 200
                        body = JSON.parse(@client.body)  
                        if body["success"]
                            @zone_id = body["result"]["id"]  
                        end 
                    end
                end

                #name = www , content = 127.0.0.1
                def create_or_update_dns_a(name, content, proxied = false)
                    type = "A"
                    # @name = name
                    if can_update? 
                        if get_dns_id(type, name)
                            update_dns(type, name, content, proxied )
                        else 
                            create_dns(type , name, content, proxied )
                        end 
                    end 
                end

                def list_all_zone(page, per_page)
                    all_zone = rest_client("#{zone_url}?status=active&page=#{page}&per_page=#{per_page}", "get" )
                    if zone && zone.code == 200
                        body = JSON.parse(zone.body)   
                    end
                end 

                def find_zone(rootdomain) 
                    zone = rest_client(list_zone_url(rootdomain), "get" )
                    if zone && zone.code == 200
                        body = JSON.parse(zone.body)  
                       if body["success"] &&  body["result"][0]
                            @zone_id = body["result"][0]["id"]  
                       end
                    else
                        raise "Http status: #{zone.code} -> find_zone"
                    end
                end

                private  

                def create_dns(type, name, content, proxied = false)
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

                def update_dns(type, name, content, proxied = false)
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
                    list_zone = rest_client(dns_url, "get", @headers )
                    if list_zone && list_zone.code == 200
                        body = JSON.parse(list_zone.body)  
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

                def get_dns_id(type, name)
                    result = rest_client(list_dns_url(type, name), "get"  )
                    if result && result.code == 200
                        body = JSON.parse(result.body)  
                       if body["success"] &&  body["result"][0]
                            @dns_id = body["result"][0]["id"] 
                       else
                            nil
                       end
                    else
                        raise "Http status: #{result.code} -> get_dns_id"
                    end
                end 
                

                def api_v4
                    "https://api.cloudflare.com/client/v4"
                end

                def zone_url
                    "#{api_v4}/zones"
                end

                def list_zone_url(rootdomain)
                    "#{zone_url}/?name=#{rootdomain}&status=active&page=1&per_page=20&order=status&direction=desc&match=all"
                end 

                def user_url
                    "#{api_v4}/user"
                end

                def accounts_url
                    "#{api_v4}/accounts"
                end
 
                def list_dns_url(type,name) 
                    "#{dns_url}?type=#{type}&name=#{name}&match=all"
                end 

                def dns_url 
                    "#{api_v4}/zones/#{zone_id}/dns_records"
                end 
                
                def update_dns_url 
                    "#{dns_url}/#{dns_id}"
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