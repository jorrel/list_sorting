# ListSorting
  Easily create links for sorting a list of records.

---

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
### Basic example

    <th><%= sort_link('Login', 'login') %></th>

outputs

    <th><a href="/users?sort=login">Login</a></th>

### Multiple fields

    <th><%= sort_link('Name', 'last_name, first_name, middle_name') %></th>

outputs

    <th><a href="/users?sort=last_name%2C+first_name%2C+middle_name">Name</a></th>

### Options

If the :default option is given, and the params contains no sort info
(meaning this current list is sorted by the default order)

    <th><%= sort_link('ID', 'id', :default => true) %></th>

then the link will be for the inverse order

    <th><a href="/users?sort=id+DESC">ID</a></th>

## Encoded Parameter

By default the sort parameter is plain; but if parameter encoding is desired, it
can be set by setting 'encoded' to true anywhere in your code (probably in environment.rb)

    ListSorting.encoded = true

### Changing the encoding script

If you want to implement your own encoding script (by default Base64 is used),
just replace these two variables with your own procs.

    ListSorting.encoding_proc = Proc.new { |string| SecretLibrary.encode(string) }
    ListSorting.decoding_proc = Proc.new { |string| SecretLibrary.decode(string) }

## Sort Parameter

ListSorting uses :sort as the default key in paramsm it can be changed as follows.

    ListSorting.sort_parameter = :s
    # example url: 'users?s=bG9naW4g


---

Copyright (c) 2008 Jorrel Ang, released under the MIT license
