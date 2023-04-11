import './models/user.dart';
import './models/room.dart';

List<User> dummy_users = [
  User(
      id: 'cs21b1027',
      name: 'Shivanshu Gupta',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1024',
      name: 'Sanidhaya Sharma',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1008',
      name: 'Deep Patel',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1035',
      name: 'Praveen raj',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1019',
      name: 'Piyush Anand',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1022',
      name: 'Prayas Raj',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1025',
      name: 'Santosh Dodhi',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1016',
      name: 'Nirdesh Gothania',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1028',
      name: 'Suraj Kumar',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1004',
      name: 'Ayush Rathore',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1014',
      name: 'Naman Kumar',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
  User(
      id: 'cs21b1002',
      name: 'Anubhav Singh',
      img: 'assets/images/cs21b1027.png',
      type: UserType.student),
];

List<Room> dummy_rooms = [
  Room(id: 'A8', students: [
    'cs21b1027',
    'cs21b1022',
    'cs21b1008',
    'cs21b1016',
    'cs21b1019',
    'cs21b1035'
  ]),
  Room(id: 'B6', students: [
    'cs21b1024',
    'cs21b1025',
    'cs21b1028',
    'cs21b1004',
    'cs21b1014',
    'cs21b1002'
  ]),
];

Set<String> dummy_attendance = {};
