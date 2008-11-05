module ListSorting
  module Controller
    def paginate(model, options = {})
      klass = model.to_s.classify.constantize
      options = options.reverse_merge(:page => params[:page] || 1)
      options[:order] = params[:sort] unless params[:sort].blank?
      klass.paginate options
    end
  end

  module Helper
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
