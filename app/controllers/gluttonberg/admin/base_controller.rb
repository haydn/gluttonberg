module Gluttonberg
  module Admin
    class BaseController < Gluttonberg::BaseController
       helper_method :current_user_session, :current_user
       before_filter :require_user
       before_filter :require_backend_access

       layout 'gluttonberg'
       unloadable

      protected


        # this method is used by sorter on asset listing by category and by collection
        def get_order
          order_type = params[:order_type].blank? ? "desc" : params[:order_type]
          case params[:order]
          when 'asset_name'
            "gb_assets.name #{order_type}"
          when 'first_name'
            "first_name #{order_type}"
          when 'email'
            "email #{order_type}"
          when 'role'
            "role #{order_type}"
          when 'member_groups'
            "name #{order_type}"
          when 'name'
            "name #{order_type}"
          when 'date-updated'
            "updated_at #{order_type}"
          when 'created_at'
            "created_at #{order_type}"
          else
            "created_at #{order_type}"
          end
        end


        # This is to be called from within a controller — i.e. the delete action —
        # and it will display a dialog which allows users to either confirm
        # deleting a record or cancelling the action.
        def display_delete_confirmation(opts)
          @options = opts
          @do_not_delete = (@options[:do_not_delete].blank?)? false : @options[:do_not_delete]

          unless @do_not_delete
            @options[:title]    ||= "Delete Record?"
            @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
          else
            @options[:title]    = "Sorry you cannot delete this record!"
            @options[:message]  ||= "It is been used by some other records."
          end
          render :template => "gluttonberg/admin/shared/delete", :layout => "/layouts/bare"
        end

        # This is to be called from within a controller — i.e. the publish/unpublish action —
        # and it will display a dialog which allows users to either confirm
        # publish/unpublish a record or cancelling the action.
        def display_generic_confirmation(name , opts)
          @options = opts
          @do_not_do = (@options[:do_not_do].blank?)? false : @options[:do_not_do]
          @name = name

          unless @do_not_do
            @options[:title]    ||= "#{@name.capitalize} Record?"
            @options[:message]  ||= "If you #{@name.downcase} this record, it will be #{@name}"
          else
            @options[:title]    = "Sorry you cannot #{@name.capitalize} this record!"
            @options[:message]  ||= "It's parent record is not #{@name.capitalize}."
          end
          render :template => "shared/generic", :layout => "/layouts/bare"

        end

        # A helper for finding shortcutting the steps in finding a model ensuring
        # it has a localization and raising a NotFound if it’s missing.
        # TODO Fixme
        def with_localization(model, id)
          result = model.first_with_localization(localization_ids.merge(:id => id))
          raise NotFound unless result
          result.ensure_localization!
          result
        end

        # Returns a hash with the locale and dialect ids extracted from the params
        # or where they're missing, it will grab the defaults.
        # TODO Do we need it anymore?
        def localization_ids
          @localization_opts ||= begin
            if params[:localization]
              ids = params[:localization].split("-")
              {:locale => ids[0]}
            else
              locale = Gluttonberg::Locale.first_default
              # Inject the ids into the params so our form fields behave
              params[:localization] = "#{locale.id}"
              {:locale => locale.id}
            end
          end
        end

        # Below is all the required methods for authentication

        def require_backend_access
          return false unless require_user
          unless current_user.have_backend_access?
            store_location
            flash[:notice] = "You dont have privilege to access this page"
            redirect_to admin_login_url
            return false
          end
        end


        def is_blog_enabled
          unless Gluttonberg::Comment.table_exists? == true
            raise CanCan::AccessDenied
          end
        end

        def store_location
          session[:return_to] = request.url
        end

        # Exception handlers
        def not_found
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_found' , :status => 404, :handlers => [:haml], :formats => [:html]
        end

        def access_denied
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/access_denied', :handlers => [:haml], :formats => [:html]
        end

        # handle NotAcceptable exceptions (406)
        def not_acceptable
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/not_acceptable', :handlers => [:haml], :formats => [:html]
        end

        def internal_server_error
          render :layout => "bare" , :template => 'gluttonberg/admin/exceptions/internal_server_error', :handlers => [:haml], :formats => [:html]
        end

    end
  end # Admin
end
