class RegistrationsController < Devise::RegistrationsController

  set_tab :account
  before_filter :authenticate_user!, :only => [:register_orcid]

  def new
    # If available, pull user's E-mail address out of the OAuth hash and pass
    # into registration form.
    
    build_params = {}
    begin
      build_params[:email] = session["omniauth"]["user_info"]["email"]
    rescue
      puts "couldn't retrieve email from oauth hash: #{$!}"
    end
    user = build_resource(build_params)
    respond_with_navigational(user){ render_with_scope :new }    
  end


  def create
    build_resource
    
    if resource.save
      set_flash_message :notice, :signed_up
      puts 'created user'
      pp resource
      #sign_in_and_redirect(resource_name, resource) # From Devise
      sign_in_and_redirect(profiles_new_path) # From Devise
      #redirect_to profiles_new_path, :notice => :signed_up
    else
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
 
  # ?? move all the orcid reg. logic into its own separate controller ??
  def register_orcid
    pp params

    # If user pushed 'no thanks' button
    ## forward to destination URL
    if params[:cancel]
      flash[:notice] = "Thank you. We will not ask you this again."
      # ToDo: need bool flag in user model to hold this
      if params[:destination]
        redirect_to params[:destination]
      else
        redirect_to root_url
      end
    end
    
    # otherwise render the default template which presents the first stage of the process
    render
  end

  def import_orcid_profile

    # based on info retrieved in the OAuth handshake, fetch the profile URL as RDF

    # Extract key properties from RDF and populate a hash
    ## private method for this 

    # Display to user for reviewing & confirmation

    # OR, if user has already confirmed the info, update the user record with data from VIVO
    
    # finally send user on to org. destination if there is one
    
  end
  
  #################### 
  private
    
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
  
end