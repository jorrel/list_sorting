ActionController::Base.__send__(:include, ListSorting::Controller)
ActionView::Base.__send__(:include, ListSorting::Helper)
