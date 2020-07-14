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
      validates :mysql_password,  :install_url, :locale
    end  
    
    validates :install_url,  url: true  
    
    before_validation :set_mysql_password
    before_validation :set_wordpress_admin_user
    before_validation :tar_later, if: :installed_changed? , only: :update
    after_create :set_mysql_user
    after_create :send_install_job
  
    def set_mysql_user 
      update_attribute(:mysql_user, "wp_blog_#{self.id}")
    end 

    def set_mysql_password 
      self.mysql_password = random_password
    end

    def set_wordpress_admin_user
      self.wordpress_user = "admin"
      self.wordpress_password = random_password  
    end

    def origin
      "#{Wordpress::Conifg.template_origin}/#{self.id}"
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
      "!0O#{random}"
    end

  end
end
