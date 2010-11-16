module ApplicationHelper
  
  def li_link_to_current(name, controller)
    if current_page?(:controller => controller)
      str = '<li class="current">' + link_to(name,controller) + '</li>'
    else
      str = '<li>' + link_to(name,controller) + '</li>'
    end
    str.html_safe
  end
  
  def show_accounts
    User.account_name_with_uuid(@current_user.uuid)
  end
  
  def primary_account_id
    User.primary_account_id(@current_user.uuid)
  end

  def nl2br(text)
    text.gsub(/(<.*?>)/, '').gsub(/\n/, '<br />').html_safe
  end
end