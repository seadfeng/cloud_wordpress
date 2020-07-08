class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(https?:\/\/[^\/]*\.[^\/]*\/.*\.gz)\z/i
      record.errors[attribute] << (options[:message] || I18n.t("activerecord.errors.models.site.attributes.origin.validator" , default: "文件包必须gz格式"))
    end
  end
end

module Wordpress
  class Template < Wordpress::Base
    acts_as_paranoid
    belongs_to :locale

    with_options presence: true do 
      validates :mysql_user, :mysql_password,  :install_url, :locale
    end  
 
	  validates :install_url,  url: true  

  end
end
