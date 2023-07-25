class CRUD {
  bool? create, read, update, delete;
  CRUD({
    this.create,
    this.read,
    this.update,
    this.delete,
  });

  Map<String, bool> encode() {
    return {
      if (create != null) 'create': create!,
      if (read != null) 'read': read!,
      if (update != null) 'update': update!,
      if (delete != null) 'delete': delete!,
    };
  }

  void load(Map<String, bool> data) {
    create = data['create'];
    read = data['read'];
    update = data['update'];
    delete = data['delete'];
  }
}

class Permissions {
  CRUD? attendance, categories, users, approvers;
  Permissions({this.attendance, this.categories, this.users, this.approvers});

  Map<String, Map<String, bool>> encode() {
    return {
      if (attendance != null) 'attendance': attendance!.encode(),
      if (categories != null) 'categories': categories!.encode(),
      if (users != null) 'users': users!.encode(),
      if (approvers != null) 'approvers': approvers!.encode(),
    };
  }

  void load(Map<String, Map<String, bool>> data) {
    if (data['attendance'] != null) {
      attendance = CRUD()..load(data['attendance']!);
    }
    if (data['categories'] != null) {
      categories = CRUD()..load(data['categories']!);
    }
    if (data['users'] != null) {
      users = CRUD()..load(data['users']!);
    }
    if (data['approvers'] != null) {
      approvers = CRUD()..load(data['approvers']!);
    }
  }
}
