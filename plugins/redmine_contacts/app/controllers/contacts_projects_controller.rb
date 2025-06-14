# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2010-2025 RedmineUP
# http://www.redmineup.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

class ContactsProjectsController < ApplicationController

  before_action :find_optional_project, :find_contact
  before_action :find_related_projects, only: [:destroy, :create]
  before_action :check_count, only: :destroy
  before_action :uniqlize_projects, only: [:destroy, :create]

  accept_api_auth :create, :destroy

  helper :contacts

  def new
    @show_form = "true"
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  rescue ::ActionController::RedirectBackError
    render text: 'Project added.', layout: true
  end

  def create
    @related_projects.each { |project| @contact.projects << project unless @contact.projects.include?(project) }
    if @contact.save
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render action: 'new' }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.js { render action: 'new' }
        format.api { render_validation_errors(@contact) }
      end
    end
  end

  def destroy
    @related_projects.each { |project| @contact.projects.delete(project) }
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render action: 'new' }
      format.api { render_api_ok }
    end
  end

  private

  def find_related_projects
    @related_projects = Project.where(id: (params[:project] && params[:project][:id]) || params[:id]).to_a
    @related_projects += Project.where(identifier: (params[:project] && params[:project][:id]) || params[:project_id] )
    raise ActiveRecord::RecordNotFound unless @related_projects.any?
    raise Unauthorized unless User.current.allowed_to?(:edit_contacts, @related_projects)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_count
    deny_access if @contact.projects.size <= 1
  end

  def find_contact
    @contact = Contact.find(params[:contact_id])
    raise Unauthorized unless @contact.editable?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def uniqlize_projects
    @contact.projects = @contact.projects.uniq
  end
end
