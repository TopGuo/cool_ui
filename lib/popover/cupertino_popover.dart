part of cool_ui;

class CupertinoPopoverButton extends StatelessWidget{
  final Widget child;
  final Widget popoverBody;
  final double popoverWidth;
  final double popoverHeight;
  final Color popoverColor;
  final double radius;
  final Duration transitionDuration;
  const CupertinoPopoverButton({
    @required this.child,
    @required this.popoverBody,
    this.popoverColor=Colors.white,
    @required this.popoverWidth,
    @required this.popoverHeight,
    this.transitionDuration=const Duration(milliseconds: 200),
    this.radius=13.0});


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
            final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
            var offset = WidgetUtils.getWidgetLocalToGlobal(context);
            var bounds = WidgetUtils.getWidgetBounds(context);
            final Widget pageChild =  CupertinoPopover(
                transitionDuration: transitionDuration,
                attachRect:Rect.fromLTWH(offset.dx, offset.dy, bounds.width, bounds.height),
                child: popoverBody,
                width: popoverWidth,
                height: popoverHeight,
                color: popoverColor,
                radius: radius,);
            return Builder(
                builder: (BuildContext context) {
                  return theme != null
                      ? Theme(data: theme, child: pageChild)
                      : pageChild;
                }
            );

          },
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black54,
          transitionDuration: transitionDuration,
          transitionBuilder: _buildMaterialDialogTransitions,);
      },
      child: child,
    );
  }

  Widget _buildMaterialDialogTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}


class CupertinoPopover extends StatefulWidget {
  final Rect attachRect;
  final Widget child;
  final double width;
  final double height;
  final Color color;
  final double radius;
  final Duration transitionDuration;

  const CupertinoPopover({
    @required this.attachRect,
    @required this.child,
    @required this.width,
    @required this.height,
    this.color=Colors.white,
    this.transitionDuration = const Duration(milliseconds: 150),
    this.radius=13.0});

  @override
  CupertinoPopoverState createState() => new CupertinoPopoverState();
}

class CupertinoPopoverState extends State<CupertinoPopover>  with TickerProviderStateMixin{
  static const double _arrowWidth = 26.0;
  static const double _arrowHeight = 13.0;

  Rect _arrowRect;
  Rect _bodyRect;
  Rect _currentArrowRect;
  Rect _currentBodyRect;
  double _currentRadius;
  Animation<double> doubleAnimation;
  AnimationController animation;

  /// 是否箭头向上
  bool get isArrowUp{
    return ScreenUtil.screenHeight > widget.attachRect.bottom + widget.height + _arrowWidth;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calcRect();
    animation = new AnimationController(
        duration: widget.transitionDuration,
        vsync: this
    );
    // Tween({T begin, T end })：创建tween（补间）
    doubleAnimation = new Tween<double>(begin: 0.0, end: 1.0).animate(animation)..addListener((){
      setState(calcAnimationRect);
    });
    animation.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    var left = _bodyRect.left;
    var top = isArrowUp?_arrowRect.top:_bodyRect.top;
    return Stack(
        children: <Widget>[
          Positioned(
            left:left,
            top:top,
            child: ClipPath(
              clipper:ArrowCliper(
                  arrowRect: _currentArrowRect,
                  bodyRect: _currentBodyRect,
                  isArrowUp: isArrowUp,
                  radius: _currentRadius
              ),
              child: Container(
//                padding: EdgeInsets.only(top:isArrowUp?_arrowHeight:0),
                color: Colors.white,
                width: widget.width,
                height: _bodyRect.height + _arrowHeight,
                child: widget.child
              ),
            ),
          )
        ]
    );
  }

  calcRect(){
    double arrowLeft = 0.0;
    double arrowTop = 0.0;
    double bodyTop = 0.0;
    double bodyLeft = 0.0;
    if(widget.attachRect.left > widget.width / 2 &&  ScreenUtil.screenWidth - widget.attachRect.right > widget.width / 2){ //判断是否可以在中间
      arrowLeft = widget.attachRect.left + widget.attachRect.width / 2  - _arrowWidth / 2;
      bodyLeft = widget.attachRect.left +  widget.attachRect.width / 2 - widget.width / 2;
    }else if(widget.attachRect.left < widget.width / 2){ //靠左
      bodyLeft = 10.0;
      arrowLeft = bodyLeft + widget.radius;
    }else{ //靠右
      bodyLeft = ScreenUtil.screenWidth - 10.0 - widget.width;
      arrowLeft = ScreenUtil.screenWidth - 10.0  - _arrowWidth - 5 - widget.radius;
    }
    if(isArrowUp){
      arrowTop = widget.attachRect.bottom;
      bodyTop = arrowTop + _arrowHeight;
    }else{
      arrowTop = widget.attachRect.top - _arrowHeight;
      bodyTop = widget.attachRect.top - widget.height - _arrowHeight;
    }
    _arrowRect = Rect.fromLTWH(arrowLeft, arrowTop, _arrowWidth, _arrowHeight);
    _bodyRect = Rect.fromLTWH(bodyLeft, bodyTop, widget.width, widget.height);
  }

  calcAnimationRect(){
    var top = isArrowUp?_arrowRect.top:_bodyRect.top;

    var middleX = (_arrowRect.left - _bodyRect.left) + _arrowRect.width /2;
    var arrowLeft = middleX + ((_arrowRect.left - _bodyRect.left) - middleX) *  doubleAnimation.value;
    var arrowTop = _arrowRect.top - top;
    var bodyLeft = middleX + (0 - middleX) *  doubleAnimation.value;
    _currentRadius = widget.radius * doubleAnimation.value;
    var bodyTop = _bodyRect.top - top;

    if(isArrowUp){
      bodyTop = arrowTop +  _arrowRect.height * doubleAnimation.value ;
    }else{
      arrowTop += _arrowRect.height *(1 - doubleAnimation.value) ;
      bodyTop = arrowTop -  _bodyRect.height * doubleAnimation.value ;
    }

    _currentArrowRect = Rect.fromLTWH(
        arrowLeft,
        arrowTop,
        _arrowRect.width *   doubleAnimation.value,
        _arrowRect.height  * doubleAnimation.value);
    _currentBodyRect = Rect.fromLTWH(
        bodyLeft,
        bodyTop,
        _bodyRect.width *   doubleAnimation.value,
        _bodyRect.height *   doubleAnimation.value);
  }
}


class ArrowCliper extends CustomClipper<Path>{
  final bool isArrowUp;
  final Rect arrowRect;
  final Rect bodyRect;
  final double radius;
  const ArrowCliper({this.isArrowUp,this.arrowRect,this.bodyRect,this.radius = 13.0});

  @override
  Path getClip(Size size) {
    Path path = new Path();

    if(isArrowUp)
    {

      path.moveTo(arrowRect.left,arrowRect.bottom); //箭头
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.top);
      path.lineTo(arrowRect.right, arrowRect.bottom);

      path.lineTo(bodyRect.right - radius,bodyRect.top); //右上角
      path.conicTo(bodyRect.right,bodyRect.top
          ,bodyRect.right,bodyRect.top + radius,1);

      path.lineTo(bodyRect.right,bodyRect.bottom - radius);  //右下角
      path.conicTo(bodyRect.right,bodyRect.bottom
          ,bodyRect.right -radius ,bodyRect.bottom,1);


      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left,bodyRect.bottom
          ,bodyRect.left ,bodyRect.bottom - radius,1);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left,bodyRect.top
          ,bodyRect.left + radius,bodyRect.top,1);
    }else{

      path.moveTo(bodyRect.left + radius,bodyRect.top);

      path.lineTo(bodyRect.right - radius,bodyRect.top); //右上角
      path.conicTo(bodyRect.right,bodyRect.top
          ,bodyRect.right,bodyRect.top + radius,1);

      path.lineTo(bodyRect.right,bodyRect.bottom - radius);  //右下角
      path.conicTo(bodyRect.right,bodyRect.bottom
          ,bodyRect.right -radius ,bodyRect.bottom,1);

      path.lineTo(arrowRect.right, arrowRect.top); //箭头
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.bottom);
      path.lineTo(arrowRect.left,arrowRect.top);

      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left,bodyRect.bottom
          ,bodyRect.left ,bodyRect.bottom - radius,1);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left,bodyRect.top
          ,bodyRect.left + radius,bodyRect.top,1);

    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(ArrowCliper oldClipper) {
    return this.isArrowUp != oldClipper.isArrowUp || this.arrowRect != oldClipper.arrowRect || this.bodyRect != oldClipper.bodyRect;
  }

}