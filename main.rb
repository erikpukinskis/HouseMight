require 'rubygems'
require 'sinatra'
require 'haml'
require 'dm-core'
require 'dm-migrations'
require 'sinatra-authentication'

use Rack::Session::Cookie, :secret => ENV['SESSION_SECRET'] || 'This is a secret key that no one will guess~'





#
# ====================================
#
#  OOH LA LA, CHECK OUT THOSE MODELS!
#
# ====================================
#


class Housemate
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :where_live, String
  property :phone_number, String
  property :veto_list, String
  property :dm_user_id, Integer
  belongs_to :dm_user
end

class DmUser
  has (n, :housemates)
end

#class Date
#  has (n, :housemates)
#  property :location, String
#  property :notes, String
#  property :pros, String
#  property :cons, String
#  property :my_veto, Bool
#end

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/test.db")
DataMapper.auto_upgrade!








#
# ================================================
#
#  PREPARE TO SUBMIT! HERE COME THE CONTROLLERS!!
#
# ================================================
#


get '/' do
  @housemates = current_user.housemates
  haml :index
end

post '/housemates' do
  current_user.housemates.create(params)
  redirect '/'
end

get '/housemates/:id' do
  @housemate = Housemate.get ( params[:id] )
  haml :housemate
end








#
# ==================================
#
#  WOW, WHAT HELPFUL HELPERS!!
#
# ==================================
#

def name
  current_user.email.split("@")[0]
end








#
# =========================
#
#  VIEWS AHEAD!!!
#
# ==========================
#

__END__

@@ layout
!!! XML
!!!
%html
  %head
    %title housemight!
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/base.css'}
  %body
    #top_bar
      %ul#account_links
        - if logged_in?
          %li Welcome #{name}!
          %li
            %a{:href => '/logout'} Log out
        - else
          %li
            %a{:href => '/login'} Log in
          %li
            %a{:href => '/signup'} Sign up
      #title
        House<i>Might</i>
    = yield

@@ index
- if logged_in?
  %form{:method => 'post', :action => '/housemates'}
    Name
    %input{:name => 'name'}
    Where do they live?
    %input{:name => 'where_live'}
    Phone number
    %input{:name => 'phone_number'}



    %input{:type => 'submit', :value => 'save'}
  %ul
    - @housemates.each do |housemate|
      %li
        %a{:href => "/housemates/"+housemate.id.to_s}= housemate.name
- else
  %p Sign up to post stuff!


@@ housemate
%h1= @housemate.name
%li= @housemate.where_live
%li= @housemate.phone_number