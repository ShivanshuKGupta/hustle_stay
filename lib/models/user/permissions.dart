class CRUD {
  static const Set<String> values = {'create', 'read', 'update', 'delete'};

  bool? operator [](String property) {
    switch (property.toLowerCase()) {
      case 'create':
        return create;
      case 'read':
        return read;
      case 'update':
        return update;
      case 'delete':
        return delete;
    }
    throw 'No such property exists: \'$property\'';
  }

  void operator []=(String property, bool? value) {
    switch (property.toLowerCase()) {
      case 'create':
        create = value;
        return;
      case 'read':
        read = value;
        return;
      case 'update':
        update = value;
        return;
      case 'delete':
        delete = value;
        return;
    }
    throw 'No such property exists: \'$property\'';
  }

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
  late CRUD attendance, categories, users, approvers;

  CRUD? operator [](String property) {
    switch (property.toLowerCase()) {
      case 'attendance':
        return attendance;
      case 'categories':
        return categories;
      case 'users':
        return users;
      case 'approvers':
        return approvers;
    }
    throw 'No such property exists: \'$property\'';
  }

  Permissions(
      {CRUD? attendance, CRUD? categories, CRUD? users, CRUD? approvers}) {
    this.attendance = attendance ?? CRUD();
    this.categories = categories ?? CRUD();
    this.users = users ?? CRUD();
    this.approvers = approvers ?? CRUD();
  }

  Map<String, Map<String, bool>> encode() {
    return {
      'attendance': attendance.encode(),
      'categories': categories.encode(),
      'users': users.encode(),
      'approvers': approvers.encode(),
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
