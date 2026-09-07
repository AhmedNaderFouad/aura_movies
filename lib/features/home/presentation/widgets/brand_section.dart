import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/brand_entity.dart';
import 'brand_card.dart';
import 'home_section_header.dart';

class BrandSection extends StatelessWidget {
  final String title;
  final List<BrandEntity> brands;
  final Function(BrandEntity) onBrandTap;

  const BrandSection({
    super.key,
    required this.title,
    required this.brands,
    required this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: title),
        SizedBox(height: 16.h),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w),
            itemCount: brands.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: BrandCard(
                  brand: brands[index],
                  onTap: () => onBrandTap(brands[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
