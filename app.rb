require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'twitter'
require 'date'


configure do
  enable :sessions
  set :logging, :true
  set :session_secret, 'secret12344321secret'
end


helpers do
  def username
    session[:identity] ? session[:identity] : 'Login'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Üzgünüm, Giriş yapamadınız. Tekrar deneyiniz veya sayfa adminine ulaşınız. ' #+ request.path
    halt erb(:login_form)
  end
end

get '/' do
    logger.info 'root directory desiniz'
    logger.info "request_ip: #{request.ip}"
    logger.info "x forwarded: #{env["HTTP_X_FORWARDED_FOR"]}"
    logger.info "remote addr: #{env['REMOTE_ADDR']}"

        @ip = request.ip
        f = File.open './public/ip.txt', 'a'
    		f.write "Ziyaretçi ip : #{@ip},  Zamanı: #{Time.now}\n"
    		f.close
        #@ip = request.env['REMOTE_ADDR']

         #@client_ip = request.remote_ip
         #@remote_ip = request.env["HTTP_X_FORWARDED_FOR"]
         #@my_ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_addr
         #@ip_addr = request.env['REMOTE_ADDR']
  erb :index
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  @username = params[:username]
  @password = params[:password]

  if @username == 'admin' && @password == '&admin&'
    session[:identity] = params['username']

    logger.info "request_ip: #{request.ip}"
    logger.info "x forwarded: #{env["HTTP_X_FORWARDED_FOR"]}"
    logger.info "remote addr: #{env['REMOTE_ADDR']}"

    loginip = request.ip
    xforwarded = env["HTTP_X_FORWARDED_FOR"]
    remote_addr = env['REMOTE_ADDR']
    f = File.open './public/loginip.txt', 'a'
    f.write "Admin ip: #{loginip}, forward ip: #{xforwarded}, remote ip: #{remote_addr}, Zamanı: #{Time.now}\n"
    f.close
  end

  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Çıkış yaptınız</div>"
end

get '/secure/tagdestek' do
  #erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  erb :tagdestek
end

post '/secure/tagdestek' do
      @consumerkey = params[:consumerkey]
      @consumersecret = params[:consumersecret]
      @accesstoken = params[:accesstoken]
      @accesstokensecret = params[:accesstokensecret]
      @tag = params[:q]
      @no = params[:no]

      logger.info "consumer_key: #{@consumerkey}"
      logger.info "consumer_secret: #{@consumersecret}"
      logger.info "access_token: #{@accesstoken}"
      logger.info "access_token_secret: #{@accesstokensecret}"

      # for jp_ahmet icin
      client = Twitter::REST::Client.new do |config|
        config.consumer_key =  @consumerkey
        config.consumer_secret = @consumersecret
        config.access_token = @accesstoken
        config.access_token_secret  = @accesstokensecret
      end

      # tweets = client.user_timeline('kullanıcıadı', count: 100, exclude: "retweets")
     client.search(params[:q]).take(params[:no].to_i).each do |tweet|
       # tweets.each do |tweet|
         begin
           logger.info "Kimden : #{tweet.user.screen_name}: ====>>> #{tweet.text}"
           logger.info "URL : #{tweet.url}"
              client.retweet(tweet)
              client.favorite(tweet)
            rescue Twitter::Error::Forbidden
           begin
             # client.unfavorite(tweet)
             next if client.favorite(tweet)
             #  client.unretweet(tweet)
             next if client.retweet(tweet)
             logger.info "#{tweet.url}"
             logger.info "Kimden : #{tweet.user.screen_name}:----->>> #{tweet.text}"
           rescue Twitter::Error::Forbidden
             # either retweet or unretweet failed and there's no way to proceed
           end
           rescue Twitter::Error::Unauthorized => e
            logger.info "Unauthorized access"

           rescue => e
         end
         #sleep 3
       end
      #flash.now[:flashes] = " Girmiş olduğunuz #{@tag} isimli tagınıza  #{@no} kez RT ve FAV desteği verilmiştir "
       erb :tagdesteksonuc
end

get '/secure/kisidestek' do
  erb :kisidestek
end

get '/secure/kisidestek' do
  @consumerkey = params[:consumerkey]
  @consumersecret = params[:consumersecret]
  @accesstoken = params[:accesstoken]
  @accesstokensecret = params[:accesstokensecret]
  @tag = params[:q]
  @no = params[:no]

  logger.info "consumer_key: #{@consumerkey}"
  logger.info "consumer_secret: #{@consumersecret}"
  logger.info "access_token: #{@accesstoken}"
  logger.info "access_token_secret: #{@accesstokensecret}"

  # for jp_ahmet icin
  client = Twitter::REST::Client.new do |config|
    config.consumer_key =  @consumerkey
    config.consumer_secret = @consumersecret
    config.access_token = @accesstoken
    config.access_token_secret  = @accesstokensecret
  end


  tweets = client.user_timeline(params[:q].to_s, params[:no].to_i).each do |tweet|
 #client.search(params[:q]).take(params[:no].to_i).each do |tweet|
   # tweets.each do |tweet|
     begin
       logger.info "Kimden : #{tweet.user.screen_name}: ====>>> #{tweet.text}"
       logger.info "URL : #{tweet.url}"
          client.retweet(tweet)
          client.favorite(tweet)
        rescue Twitter::Error::Forbidden
       begin
         # client.unfavorite(tweet)
         next if client.favorite(tweet)
         #  client.unretweet(tweet)
         next if client.retweet(tweet)
         logger.info "#{tweet.url}"
         logger.info "Kimden : #{tweet.user.screen_name}:----->>> #{tweet.text}"
       rescue Twitter::Error::Forbidden
         # either retweet or unretweet failed and there's no way to proceed
       end
       rescue Twitter::Error::Unauthorized => e
        logger.info "Unauthorized access"

       rescue => e
     end
     #sleep 3
   end
   erb :kisidesteksonuc
end

get '/index' do
	erb :index
end


get '/visit' do
	erb :visit
end

get '/contacts' do
	erb :contacts
end

post '/contacts' do
	erb :contacts

	@email = params[:email]
	@msg = params[:msg]

		@title = 'Teşekkür ederiz!'
		@message = "Sayın #{@email}, mesajınız bize ulaşmıştır."

		f = File.open './public/contacts.txt', 'a'
		f.write "Email: #{@email}, message: #{@msg}\n"
		f.close
		erb :message

end


post '/visit' do
	erb :visit

	@username = params[:username]
	@phone =     params[:phone]
	@date_time = params[:date_time]
	@master = params[:master]

			@title = 'Thank you!'
			@message = "Dear #{@username}, #{@master} be waiting for you at #{@date_time}, this is your phone: #{@phone}"


			f = File.open './public/users.txt', 'a'
			f.write "User: #{@username}, Phone: #{@phone}, Date and time: #{@date_time}, master #{@master}\n"
			f.close
			erb :message

end
