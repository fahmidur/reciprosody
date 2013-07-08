class CreateMessagesTable < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :topic
      t.text :body
      t.references :received_messageable, :polymorphic => true
      t.references :sent_messageable, :polymorphic => true
      t.boolean :opened, :default => false
      t.boolean :recipient_delete, :default => false
      t.boolean :sender_delete, :default => false
      t.timestamps

      # ancestry
      t.string :ancestry
    end

    add_index :messages, [:sent_messageable_id, :received_messageable_id], :name => "acts_as_messageable_ids"
    add_index :messages, :ancestry
  end

  def self.down
    drop_table :messages
  end
end
