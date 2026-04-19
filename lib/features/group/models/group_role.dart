enum GroupRole { leader, coLeader, member }

// Member tuple: (name, count, isYou, role, userId)
typedef GroupMember = (String, int, bool, GroupRole, String);
