module Wordpress
    module Validates
        extend ActiveSupport::Concern

        class EmailValidator < ActiveModel::EachValidator
            def validate_each(record, attribute, value)
                unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
                    record.errors[attribute] << (options[:message] || "is not an email")
                end
            end
        end
        
        class UrlValidator < ActiveModel::EachValidator
            def validate_each(record, attribute, value)
                unless value =~ URI::regexp
                    record.errors[attribute] << (options[:message] || "is not an url")
                end
            end
        end 
        
        class DomainValidator < ActiveModel::EachValidator
            def validate_each(record, attribute, value)
                unless value =~ /\A([^\/]*\.[^\/]*)\z/i
                record.errors[attribute] << (options[:message] || I18n.t("activerecord.errors.models.site.attributes.origin.validator" , default: "域名有误"))
                end
            end
        end

        class RedirectUrlValidator < ActiveModel::EachValidator
            def validate_each(record, attribute, value)
                unless value =~ /\A(^\/.*)\z/i
                record.errors[attribute] << (options[:message] || I18n.t("activerecord.errors.models.site.attributes.redirect_url.validator" , default: "必须'/'开头的站内链接"))
                end
            end
        end
    end
end
