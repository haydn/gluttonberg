# encoding: utf-8

module Gluttonberg
  module Admin
    module Content
      class BlogsController < Gluttonberg::Admin::BaseController
        before_filter :is_blog_enabled
        before_filter :find_blog, :only => [:show, :edit, :update, :delete, :destroy]
        before_filter :require_super_admin_user , :except => [:index]
        before_filter :authorize_user , :except => [:destroy , :delete]
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]
        record_history :@blog

        def index
          @blogs = Blog.paginate(:per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items"), :page => params[:page])
          if @blogs && @blogs.size == 1
            redirect_to admin_blog_articles_path(@blogs.first)
          end
        end

        def show
          if @blog
            redirect_to admin_blog_articles_path(@blog)
          else
            redirect_to admin_blog_path
          end
        end

        def new
          @blog = Blog.new
        end

        def create
          @blog = Blog.new(params[:gluttonberg_blog])
          if @blog.save
            flash[:notice] = "The blog was successfully created."
            redirect_to admin_blogs_path
          else
            render :edit
          end
        end

        def edit
          unless params[:version].blank?
            @version = params[:version]
            @blog.revert_to(@version)
          end
        end

        def update
          @blog.current_slug = @blog.slug
          @blog.assign_attributes(params[:gluttonberg_blog])
          @blog.previous_slug = @blog.current_slug if @blog.slug_changed?
          if @blog.save
            flash[:notice] = "The blog was successfully updated."
            redirect_to admin_blogs_path
          else
            flash[:error] = "Sorry, The blog could not be updated."
            render :edit
          end
        end

        def delete
          display_delete_confirmation(
            :title      => "Delete Blog '#{@blog.name}'?",
            :url        => admin_blog_path(@blog),
            :return_url => admin_blogs_path,
            :warning    => "This will delete all the articles that belong to this blog"
          )
        end

        def destroy
          if @blog.delete
            flash[:notice] = "The blog was successfully deleted."
            redirect_to admin_blogs_path
          else
            flash[:error] = "There was an error deleting the blog."
            redirect_to admin_blogs_path
          end
        end


        protected

          def find_blog
            @blog = Blog.where(:id => params[:id]).first
          end

          def authorize_user
            authorize! :manage, Gluttonberg::Blog
          end

          def authorize_user_for_destroy
            authorize! :destroy, Gluttonberg::Blog
          end

      end
    end
  end
end
