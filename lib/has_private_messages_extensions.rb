module Professionalnerd #:nodoc:
  module SimplePrivateMessages #:nodoc:
    module HasPrivateMessagesExtensions #:nodoc:
      def self.included(base) #:nodoc:
        base.extend ActMethods
      end

      module ActMethods
        # Sets up a model have private messages, defining the child class as specified in :class_name (typically "Messages").
        # Provided the following instance messages:
        # *  <tt>sent_messages</tt> - returns a collection of messages for which this object is the sender.
        # *  <tt>received_messages</tt> - returns a collection of messages for which this object is the recipient.
        def has_private_messages(options = {})
          options[:class_name] ||= 'Message'

          unless included_modules.include? InstanceMethods
            class_attribute :options
            table_name = options[:class_name].constantize.table_name

#            has_many :sent_messages,
#                     :class_name => options[:class_name],
#                     :foreign_key => 'sender_id',
#                     :includes => :recipient,
#                     :order => "#{table_name}.created_at DESC",
#                     :conditions => ["#{table_name}.sender_deleted = ?", false]
#
#            has_many :received_messages,
#                     :class_name => options[:class_name],
#                     :foreign_key => 'recipient_id',
#                     :includes => :sender,
#                     :order => "#{table_name}.created_at DESC",
#                     :conditions => ["#{table_name}.recipient_deleted = ?", false]

            has_many :sent_messages, -> { where(:sender_deleted => false).includes(:recipient).order(:created_at).reverse_order },
                :class_name => options[:class_name],
                :foreign_key => :sender_id

            has_many :received_messages, -> { where(:recipient_deleted => false).includes(:sender).order(:created_at).reverse_order },
               :class_name => options[:class_name],
               :foreign_key => :recipient_id

            extend ClassMethods
            include InstanceMethods
          end
          self.options = options
        end
      end

      module ClassMethods #:nodoc:
        # None yet...
      end

      module InstanceMethods
        # Returns true or false based on if this user has any unread messages
        def unread_messages?
          unread_message_count > 0
        end

        # Returns the number of unread messages for this user
        def unread_message_count
          received_messages.where(:read_at => nil).count
        end
      end
    end
  end
end

if defined? ActiveRecord
  ActiveRecord::Base.class_eval do
    include Professionalnerd::SimplePrivateMessages::HasPrivateMessagesExtensions
  end
end