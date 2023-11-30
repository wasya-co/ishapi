
Office::Emailtag.find_or_create_by!({ slug: Office::Emailtag::INBOX })
puts 'Emailtag `inbox` exists.'
Office::Emailtag.find_or_create_by!({ slug: Office::Emailtag::TRASH })
puts 'Emailtag `trash` exists.'
