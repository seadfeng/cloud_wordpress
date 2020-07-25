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
      validates :mysql_password,  :install_url, :locale, :name
      validates_uniqueness_of :name, case_sensitive: true, allow_blank: false      

    end  
    
    validates :install_url,  url: true  
    
    before_validation :set_mysql_password 
    before_validation :set_wordpress_admin_user
    before_validation :tar_later, if: :installed_changed? , on: :update
    after_create :set_mysql_user
    after_create :send_install_job
    

    def database
      self.mysql_user
    end
  
    def set_mysql_user 
      update_attribute(:mysql_user, "wp_template_#{self.id}")
    end 

    def set_mysql_password 
      self.mysql_password = random_password if mysql_password.blank?
    end

    def set_wordpress_admin_user
      self.wordpress_user = "admin"
      self.wordpress_password = random_password  if wordpress_password.blank?
    end

    def origin
      "#{Wordpress::Config.template_origin}/#{self.id}"
    end

    def origin_wordpress
      "#{origin}/wordpress"
    end

    def down_url
      "#{origin}/#{template_tar_file}"
    end 

    def template_tar_file
      "wp-#{self.id}.tar.bz2"
    end

    def reset_password 
      update_attribute(:wordpress_password, random_password) 
      Wordpress::TemplateResetPasswordJob.perform_later(self)
    end

    def send_install_job
      Wordpress::TemplateInstallJob.perform_later(self)
    end

    def tar_later
      Wordpress::TemplateTarJob.perform_later(self)
    end

    def tar_now
      Wordpress::TemplateTarJob.perform_now(self)
    end

    private 

    def random_password
      random = SecureRandom.urlsafe_base64(nil, false) 
      "i-#{random}"
    end

  end
end
