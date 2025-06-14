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

class CreateAddresses < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def up
    create_table :addresses do |t|
      t.string :street1
      t.string :street2
      t.string :city
      t.string :region
      t.string :postcode
      t.string :country_code, :limit => 2
      t.text :full_address
      t.string :address_type, :limit => 16
      t.references :addressable, :polymorphic => true
      t.timestamps :null => false
    end
    add_index :addresses, [ :addressable_id, :addressable_type ]
    add_index :addresses, :address_type

    Contact.all.each do |asset|
      Address.create(:street1 => asset.attributes["address"].gsub(/\n/, ' ').first(250), :full_address => asset.attributes["address"], :address_type => "business", :addressable => asset) unless asset.attributes["address"].blank?
    end

    remove_column(:contacts, :address)
  end

  def down
    add_column :contacts, :address, :text
    drop_table :addresses
  end

end
