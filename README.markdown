# ListSorting
  Easily create links for sorting a list of records.


# Requirements
  Requires will_paginate


# Example
## Controller
    class UsersController < ApplicationController
      def index
        @users = paginate :users, :order => 'login'
        # or
        @users = paginate @group.users, :order => 'login'
      end
    end

## View
    <th><%= sort_link('Login', 'login') %></th>

    <!-- this works -->
    <th><%= sort_link('Name', 'last_name, first_name, middle_name') %></th>


Copyright (c) 2008 Jorrel Ang, released under the MIT license
