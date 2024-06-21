class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent(
      {required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Brampton Tiffins',
      image: 'assets/image/t3.jpeg',
      discription:
          "Brampton Tiffin Service Brings You the Best of Home-Cooked Meals. Browse Brampton tiffins near your area which makes easy and time saving delivery." 
         ),
  UnbordingContent(
      title: 'Chat with Sellers',
      image: 'assets/image/t1.jpg',
      discription:
          "Live chat, Share ideas with Customers or Sellers. Get customized meal plans and on-time delivery of your favorite dishes. "
         ),
  UnbordingContent(
      title: 'Home-made food',
      image: 'assets/image/t2.jpg',
      discription:
          "Get Fresh and Nutritious Home-made Tiffin Delivered Daily. Fresh, healthy and delicious meals delivered right to your doorstep "
         ),
];
