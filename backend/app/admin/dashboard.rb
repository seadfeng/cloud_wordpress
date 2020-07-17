ActiveAdmin.register_page "Dashboard" do
    init_controller
    menu priority: 0, label: proc{ I18n.t("active_admin.dashboard") }

    content title: proc{ I18n.t("active_admin.dashboard") } do
        # Groupdate.time_zone = "Beijing"
        Groupdate.day_start = 0

        columns do 
            blogs = Wordpress::Blog.published
            days_90 = blogs.where( "published_at >= ?", 3.months.ago  )
            column do 
              panel "90天发布 - #{days_90.count}个" do  
                div line_chart days_90.group_by_day(:published_at ).count 
              end
            end 
            column do  
                panel "博客主机分布" do 
                    div pie_chart Wordpress::Blog.all.joins(:server).group("#{Wordpress::Server.table_name}.name").order("count_all desc").count 
                end 
            end 
        end #columns 
    end # content
end
