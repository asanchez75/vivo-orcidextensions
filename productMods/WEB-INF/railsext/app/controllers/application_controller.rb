class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  alias :logged_in? :user_signed_in?

  
  protect_from_forgery

  def current_user
    puts "in current_user(), found @current_user="
    pp @current_user
    return @current_user
  end

  def authenticate_user_vivo
    puts "in custom authn routine for VIVO user"

    puts "Rails params from authz form="
    pp params
    
    puts "servlet request="
    pp servlet_request
    puts "params from servlet request="
    servlet_request_params = servlet_request.getParameterMap()
    pp (servlet_request_params || "")

    #return true
    servlet_request.getSession.setAttribute("edu.cornell.mannlib.vitro.webapp.beans.DisplayMessage","[message from OAuth Rails app]")

    pp session
    pp servlet_request

    puts "profa enum .each:"
    
    servlet_request.getSession.getAttributeNames.each {|i| 
      puts i + " => " 
      pp servlet_request.getSession.getAttribute(i) 
    }

    puts "Full request URL=" + servlet_request.request_uri + (servlet_request.query_string|| "")
    

    session = servlet_request.getSession()
    
    loginStatus = session.get_attribute("loginStatus")
    if loginStatus
      puts "Got loginStatus bean asString=" + loginStatus.to_string
      
      #if user_account = loginStatus.current_user
      #  puts 'got user account'
      #  pp user_account
      #end
    end
    
    
    loginHandler = session.getAttribute("loginHandler")    

    if loginHandler
      puts "user.toString=" + loginHandler.toString()
      
      if loginHandler.loginStatus == "authenticated"
        puts "VIVO user " + loginHandler.getLoginName() + " <-- " + loginHandler.getUserURI()
        # PROFA loginHandler.login_name og .user_uri? 
        # return true
        # NO need to set instance (?) variable representing the user. Elsewhere need to 
        # implement user_signed_in? which is used elsewhere to check if user is authenticated

        # Instantiate user 
        puts "creating-or-finding Rails user w/ email=" + loginHandler.login_name
        @current_user = User.find_by_email(loginHandler.login_name)
        if !@current_user
          puts "   gotta create new user"
          @current_user = User.new(:email => loginHandler.login_name)
          puts 'saving user record to database'
          @current_user.save!
           # TODO add profile URI and maybe other available info from VIVO account
        end
        pp @current_user

      end
    else
      puts "User is not logged in, redirecting to VIVO authn form"
      redirect_to "/authenticate?" + URI.escape("afterLogin=" + servlet_request.request_uri + "?" + (servlet_request.query_string|| ""))
    end
    
    
    #redirect_to "/people"

    # IF not logged in
      # redirect to /authenticate?afterLogin + URL back here
    # ELSE
      # check session attribute to determine logged-in status + whether authorizd or not?
      # return true if all adds up
    
    
  end

  alias :login_required :authenticate_user_vivo


  # VANTAR nyjan current_user helper, til ad fa unique ID (E-mail??) fyrir VIVO notanda
  
  # VANTAR nyjan user_signed_in? helper

end
