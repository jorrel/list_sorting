require 'enumerator'
require 'base64'

module ListSorting
  #
  # ListSorting.encoded
  #
  # if set to true, encodes the sorting parameter
  #
  mattr_accessor :encoded
  self.encoded = false

  #
  # ListSorting.encoding_proc
  #
  # what is used for encoding the sorting parameter if
  # ListSorting.encoded is set to true
  #
  mattr_accessor :encoding_proc
  self.encoding_proc = Proc.new { |s|
    s += ' ' until (s.size % 3).zero? # avoid '='s at the end
    Base64.encode64(s).chomp
  }

  #
  # ListSorting.decoding_proc
  #
  # what decodes the sorting parameter (reverse of ListSorting.encoding_proc)
  #
  mattr_accessor :decoding_proc
  self.decoding_proc = Proc.new { |s| Base64.decode64(s).strip }

  #
  # ListSorting.sort_parameter
  #
  # the 'sort' part in '/users?sort=login'
  #
  mattr_accessor :sort_parameter
  self.sort_parameter = :sort



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

      sort = ListSorting.extract_sort_field_from params
      options[:order] = sort if sort

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
    #  sort_link('Username', 'username', :default => true)
    #    if no sorting in params, the link will be for the reverse order
    #    # <a href="/users?sort=username+DESC">Username</a>
    #
    #  sort_link('Last Updated', 'updated_at DESC')
    #    # <a href="/users?sort=updated_at+DESC">Last Updated</a>
    #    if currently selected:
    #    # <a href="/users?sort=updated_at" class="current-sort desc">Last Updated</a>
    #
    #  sort_link('Name', 'last_name, first_name')
    #    # <a href="/users?sort=last_name,+first_name">Name</a>
    #
    def sort_link(label, field, options = {})
      default = options.delete(:default)
      sort = ListSorting.extract_sort_field_from params
      base = Proc.new { |f| f.sub(/\s*(ASC|DESC)$/,'') }
      current =
        if sort.blank?
          false
        elsif field =~ /,/
          fields, sorting = field.split(/\s*,\s*/), sort.split(/\s*,\s*/)
          fields.size == sorting.size and fields.enum_for(:each_with_index).all? { |f, i| sorting[i] =~ /^#{base.call(f)}(\s(ASC|DESC))?$/i }
        else
          sort =~ /^#{base.call(field)}(\s(ASC|DESC))?$/i
        end

      if current
        field = ActiveRecord::Base.__send__(:reverse_sql_order, sort).gsub(/\sASC$/i, '')
      elsif sort.blank? and default
        field = ActiveRecord::Base.__send__(:reverse_sql_order, field).gsub(/\sASC$/i, '')
      end

      options[:class] = 'current-sort ' + ((field =~ /DESC$/i) ? 'asc' : 'desc') if current
      field = ListSorting.encode(field)
      link_to label, url_for(ListSorting.sort_parameter => field, :params => params), options
    end
  end



  class << self
    alias :encoded? :encoded

    def encode(str)
      encoded? ? encoding_proc.call(str) : str
    end

    def decode(str)
      encoded? ? decoding_proc.call(str) : str
    end

    def extract_sort_field_from(params = {})
      (s = params[sort_parameter]) ? decode(s) : nil
    end
  end
end
