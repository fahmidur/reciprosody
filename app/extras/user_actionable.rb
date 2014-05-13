module UserActionable
	def user_action_from(user, action_sym, extra={}, notifier=nil)
		return unless user	
		action = self.user_actions.build
		action.user_id = user.id

		user_action_type = UserActionType.find_by_name(action_sym)
		return unless user_action_type
		
		action.user_action_type_id = user_action_type.id

		extra.each do |k,v|
			action.update(k => v)
		end
		action.save!
		return action unless action.visible
		notifier.call(action) if notifier
		return action
	end
end