class <%= privileges_class_name %> < ApplicationController  
  verify :method => :post, :only => [ :create, :update],
       :redirect_to => { :action => :list }
  
  def index
    redirect_to :action => :list
  end
  
  def list
    @privileges = ActiveAcl::Privilege.find(:all, :order => 'section ASC, value ASC')
  end
  
  def edit
    redirect_to :action => :list and return false unless params[:id]
    begin
      @privilege = ActiveAcl::Privilege.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = 'Privilege not found'
      redirect_to :action => :list and return false
    end
  end
  
  def update
    redirect_to :action => :list and return false if params['commit'] == 'Cancel'
    
    begin
      @privilege = ActiveAcl::Privilege.find(params[:id].to_i)
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = 'Privilege not found'
      redirect_to :action => :list and return false
    end
    
    if (@privilege.update_attributes(params[:privilege]))
      flash[:success] = 'Privilege successfully updated'
      redirect_to :action => :list and return false
    else
      flash.now[:error] = 'There was an error updating the Privilege'
      @title = 'Edit Privilege'
      render :action => :edit
    end   
  end
  
  def delete
    redirect_to :action => :list and return false unless params[:id]
    begin
      privilege = ActiveAcl::Privilege.find(params[:id])
      privilege.destroy
      flash[:success] = 'Privilege successfully deleted'
    rescue ActiveRecord::RecordNotFound => e
      flash[:error] = 'Privilege not found'
    end
          
    redirect_to :action => :list and return false
  end
end