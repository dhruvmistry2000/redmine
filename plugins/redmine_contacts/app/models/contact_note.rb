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

class ContactNote < Note
  include Redmine::SafeAttributes

  belongs_to :contact, foreign_key: :source_id

  safe_attributes 'subject', 'type_id', 'content', 'source', 'author_id'

  acts_as_activity_provider type: 'contacts',
                            permission: :view_contacts,
                            author_key: :author_id,
                            scope: joins(contact: :projects).where(source_type: 'Contact') if ActiveRecord::Base.connection.table_exists?(Note.table_name)

  scope :visible,
        lambda { |*args| joins([contact: :projects]).
                         where(Contact.visible_condition(args.shift || User.current, *args) +
                                          " AND (#{ContactNote.table_name}.source_type = 'Contact')") }

  acts_as_attachable view_permission: :view_contacts,
                     delete_permission: :edit_contacts
end
