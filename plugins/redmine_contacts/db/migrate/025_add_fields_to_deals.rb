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

class AddFieldsToDeals < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def self.up
    change_column :deals, :duration, :integer, :default => 1
    add_column :deals, :due_date, :timestamp
    add_column :deals, :probability, :integer

  end

  def self.down
    remove_column :deals, :due_date
    remove_column :deals, :probability
  end
end
