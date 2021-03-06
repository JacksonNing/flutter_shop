import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_shop/model/category.dart';
import 'package:flutter_shop/model/categoryGoodsList.dart';
import 'package:flutter_shop/provide/category_goods_list.dart';
import 'package:flutter_shop/provide/child_category.dart';
import 'package:flutter_shop/service/service_method.dart';
import 'package:provide/provide.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品分类'),
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[RightCategoryNavState(),CategoryGoodsList()],
            )
          ],
        ),
      ),
    );
  }
}

//左侧大类导航
class LeftCategoryNav extends StatefulWidget {
  @override
  _LeftCategoryNav createState() => _LeftCategoryNav();
}

class _LeftCategoryNav extends State<LeftCategoryNav> {
  List list = [];
  var lastIndex = 0;

  @override
  void initState() {
    _getCategory();
    _getGoodsList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(width: 1,color: Colors.black12))
      ),
      child: Container(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context,index){
            return _leftInkWell(index);
          },
        ),
      ),
    );
  }


  Widget _leftInkWell(int index) {
    bool isclick = (index == lastIndex);
    return InkWell(
      onTap: () {
        setState(() {
          lastIndex = index;
        });
        var childList = list[index].bxMallSubDto;
        var categoryId = list[index].mallCategoryId;

        Provide.value<ChildCategory>(context).getChildCategory(childList);
        _getGoodsList(categoryId: categoryId);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10, top: 20),
        decoration: BoxDecoration(
          color: isclick ? Color.fromRGBO(236, 236, 236, 1.0) : Colors.white,
          border:
          Border(bottom: BorderSide(width: 1, color: Colors.black12)),
        ),
        child: Text(
          list[index].mallCategoryName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }

  void _getCategory() async {
    await request('getCategory').then((val) {
      var data = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(data);
      setState(() {
        list = category.data;
      });
      Provide.value<ChildCategory>(context)
          .getChildCategory(list[0].bxMallSubDto);
    });
  }


  void _getGoodsList({String categoryId})async{

    var data={

      'categoryId':categoryId==null?'4':categoryId,
      'CategorySubId':'',
      'page':1
    };

    await request('getMallGoods',formData: data).then((val){
      var data=json.decode(val.toString());
      CategoryGoodsListModel goodsList = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
    });


  }



}

class RightCategoryNavState extends StatefulWidget {

  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNavState> {

  @override
  Widget build(BuildContext context) {
    return Provide<ChildCategory>(
      builder: (context, child, childCategory) {
        return Container(
            height: ScreenUtil().setHeight(80),
            width: ScreenUtil().setWidth(570),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(width: 1,
                color: Colors.black12)) ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: childCategory.childCategoryList.length,
            itemBuilder: (context,index){
              return _rightInkWell(childCategory.childCategoryList[index]);
            },
          ),
        );
      },
    );
  }

  Widget _rightInkWell(BxMallSubDto item){
    return InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Text(
          item.mallSubName,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),
        ),
      ),
    );
  }
}

class CategoryGoodsList extends StatefulWidget{
  _CategoryGoodsListState createState() =>_CategoryGoodsListState();
}
class _CategoryGoodsListState extends State<CategoryGoodsList> {
  @override
  Widget build(BuildContext context) {
    return Provide<CategoryGoodsListProvide>(
      builder: (context,child,data){
        return Expanded(
          child: Container(
            width: ScreenUtil().setWidth(570),
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
                itemCount: data.goodsList.length,
                itemBuilder: (context,index){
                  return _listWidget(data.goodsList, index);
                }),
          )

        );
      },
    );
  }

  Widget _goodsImage(List newList,index){
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(newList[index].image),
    );
  }

  Widget _goodsName(List newsList,index){
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(
        newsList[index].goodsName,
        maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: ScreenUtil().setSp(28)),

      ),
    );
  }

  Widget _goodsPrice(List newList,index){


    return Container(
      margin: EdgeInsets.only(top: 20.0),
      width: ScreenUtil().setWidth(370),

      child: Row(
        children: <Widget>[
          Text(
            '价格; ¥${newList[index].presentPrice}',
            style:
            TextStyle(color: Colors.pink, fontSize: ScreenUtil().setSp(30)),
          ),
          Text(
            '¥${newList[index].oriPrice}',
            style:
            TextStyle(color: Colors.black26, decoration: TextDecoration.lineThrough),
          )
        ],
      ),
    );

  }

  Widget _listWidget(List newList,index){

    return InkWell(
      onTap: (){},
      child: Container(

        padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
        decoration: BoxDecoration(

          color: Colors.white,

          border: Border(bottom: BorderSide(width: 1.0,color: Colors.black12)),

        ),
        child: Row(
          children: <Widget>[
            _goodsImage(newList, index),
            Column(
              children: <Widget>[
                _goodsName(newList, index),
                _goodsPrice(newList, index),
              ],
            )
          ],
        ),
      ),
    );


  }



}






















