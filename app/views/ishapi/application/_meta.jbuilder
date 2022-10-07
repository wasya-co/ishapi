
#
# ishapi / application / _meta
#

json.created_at  item.created_at
json.updated_at  item.updated_at
json.username    item.user_profile.name if item.user_profile
json.subhead     item.subhead
json.description item.descr
