FactoryGirl.define do
	factory :corpus do |corpus|
		corpus.name 'Boston Radio News Corpus'
		corpus.language 'English'
		corpus.hours 1
		corpus.num_speakers 1
		corpus.description "<p>Lorem Corpus One ipsum dolor sit amet, consectetur adipiscing elit. Nullam egestas odio vitae nisi fermentum sed tincidunt ante vulputate. Aenean at sem ipsum, fermentum iaculis eros. Cras bibendum porta augue id congue. Aliquam dictum est sit amet sapien facilisis non molestie dolor luctus. Fusce sed urna eget magna adipiscing mollis eu ut ipsum. Praesent condimentum condimentum elit, eu pulvinar libero vulputate non. Quisque molestie justo volutpat enim mollis vulputate</p><p>Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Nunc ultricies magna ut magna varius tempus. Maecenas non consectetur nisl. Nullam interdum tortor ut metus convallis molestie. Proin tortor sem, vehicula eu blandit quis, hendrerit vitae tortor. Morbi id erat nec massa suscipit placerat. Nunc accumsan enim eget arcu consequat vitae accumsan sem dictum. Nunc venenatis nisl at elit volutpat ut iaculis quam lacinia. Vivamus faucibus, leo sed gravida accumsan, libero nibh gravida nibh, ac dictum felis velit in velit. Quisque diam arcu, lacinia eu tincidunt sed, pulvinar id purus. Duis facilisis rutrum euismod. Quisque nec tristique odio. Aenean tincidunt tincidunt metus vel pretium. Mauris aliquet tortor nec neque pharetra id aliquet ligula accumsan.</p><p>Maecenas ipsum sapien, varius ut auctor quis, volutpat ut libero. Aliquam congue adipiscing eros eget porta. Suspendisse imperdiet, sem non egestas feugiat, nulla elit rhoncus lorem, vitae hendrerit dolor orci et metus. Pellentesque quis adipiscing purus. Duis ligula lorem, sodales ac bibendum at, blandit eu quam. Maecenas tempor accumsan enim, ac tristique ligula varius sed. Fusce vitae felis mi, eu iaculis erat.</p>"
	end

	factory :membership do |membership|
		user
		trait :owner do
			membership.role 'owner'
		end
	end

	factory :user do |user|
		user.name "Syed Reza"
	end
end