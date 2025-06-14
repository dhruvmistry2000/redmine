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

class TasksController < ApplicationController

  before_action :find_project_by_project_id, :authorize, :except => [:index]
  before_action :find_optional_project, :only => :index
  before_action :find_taskable, :except => [:index, :add, :close]
  before_action :find_issue, :except => [:index, :new]

  def new
    issue = Issue.new
    issue.subject = params[:task_subject]
    issue.project = @project
    issue.tracker_id = params[:task_tracker]
    issue.author = User.current
    issue.due_date = params[:due_date]
    issue.assigned_to_id = params[:assigned_to]
    issue.description = params[:task_description]
    issue.status = IssueStatus.default
    if issue.save
      flash[:notice] = l(:notice_successful_add)
      @taskable.issues << issue
      @taskable.save
      redirect_to :back
      return
    else
      redirect_to :back
    end
  end

  def add
    @show_form = 'true'

    if params[:source_id] && params[:source_type] && request.post?
      find_taskable
      @taskable.issues << @issue
      @taskable.save
    end

    taskable_name = @taskable.class.name.underscore

    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html "issue_#{taskable_name}s", :partial => "issues/#{taskable_name}s"
        end
      end
    end
  end

  def delete
    @issue.taskables.delete(@taskable)
    taskable_name = @taskable.class.name.underscore
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html "issue_#{taskable_name}s", :partial => "issues/#{taskable_name}s"
        end
      end
    end
  end

  def close
    @issue.status = IssueStatus.find(:first, :conditions =>  { :is_closed => true })
    @issue.save
    respond_to do |format|
      format.js do
        render :update do |page|
          page["issue_#{params[:issue_id]}"].visual_effect :fade
        end
      end
      format.html { redirect_to :back }
    end
  end

  private

  def find_taskable
    klass = Object.const_get(params[:source_type].camelcase)
    @taskable = klass.find(params[:source_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_issue
    @issue = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
