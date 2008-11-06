module ListSorting
  module Controller
    #
    # Paginate the model
    #
    # The model can be supplied as the name of the class or the class itself.
    # Note that the model has to have a 'paginate' method. (will_paginate usually)
    #
    # == Params
    #  model   = model name or model class
    #  options = paginate/find options
    #
    # == Examples
    #  paginate :users
    #  paginate @group.users
    #
    def paginate(model, options = {})
      if String === model or Symbol === model # user gave the model name
        model = model.to_s.classify.constantize
      end	
      options = options.reverse_merge(:page => params[:page] || 1)
      options[:order] = params[:sort] unless params[:sort].blank?
      model.paginate options
    end
  end

  module Helper
    #
    # Create a link that sorts the current list
    #
    # It also adds 'current-sort' and 'asc' or 'desc' class names to the
    # link if the link is for the current sorting order.
    #
    # == Params
    #  label   = label of the link
    #  field   = column/field name of the sort
    #  options = options + html options of the link combined
    #
    # == Options
    #  :default
    #    Identify this link as the default sorting order; therefore if the list is not
    #    custom sorted, then the link generated will be for the reverse order.
    #
    # == Examples
    #  sort_link('Country', 'country')
    #    # <a href="/users?sort=country">Country</a>
    #    if currently selected:
    #    # <a href="/users?sort=country+DESC" class="current-sort asc">Country</a>
    #
    #  sort_link('Login', 'login', :default => true)
    #    # <a href="/users?sort=login+DESC">Login</a>
    #    if currently selected:
    #    # <a href="/users?sort=login" class="current-sort desc">Login</a>
    #
    #  sort_link('Name', 'last_name, first_name')
    #    # <a href="/users?sort=last_name,+first_name">Name</a>
    #
    def sort_link(label, field, options = {})
      default = options.delete(:default) || false
      if (current = (params[:sort] =~ /^#{field}(\s(ASC|DESC))?$/i)) or (params[:sort].blank? and default)
        field = ActiveRecord::Base.__send__(:reverse_sql_order, field).gsub(/\sASC$/i, '')
      end
      options[:class] = 'current-sort ' + ((field =~ /DESC$/i) ? 'asc' : 'desc') if current
      link_to label, url_for(:sort => field), options
    end
  end
end
