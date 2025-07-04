import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/utils/asset_utils.dart';
import 'package:flutter_boilerplate/ui/views/compress_image/compress_image_viewmodel.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ThumbNailImageList extends StatelessWidget {
  final CompressImageViewModel? viewModel;
  final List<AssetEntity> photosList;

  const ThumbNailImageList({
    Key? key,
    this.viewModel,
    required this.photosList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return imageList(context, viewModel, photosList);
  }
}

Widget imageList(
  BuildContext context,
  CompressImageViewModel? viewModel,
  List<AssetEntity> photosList,
) {
  const int maxDisplayImages = 10;
  final int totalImages = photosList.length;
  final int displayCount = totalImages > maxDisplayImages ? 10 : totalImages;
  final int remainingCount = totalImages - displayCount;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayCount + (remainingCount > 0 ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < displayCount) {
              // Display actual image
              return _buildImageItem(photosList[index], viewModel);
            } else {
              // Display remaining count box
              return _buildRemainingCountBox(remainingCount);
            }
          },
        ),
      ),
    ],
  );
}

Widget _buildImageItem(
  AssetEntity asset,
  CompressImageViewModel? viewModel,
) {
  return Container(
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.grey.shade300.withOpacity(0.5),
        width: 1,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: Stack(
        children: [
          AssetEntityImage(
            asset,
            fit: BoxFit.cover,
            width: 70,
            height: 70,
            isOriginal: false,
            thumbnailSize: const ThumbnailSize.square(200),
          ),
          //show full widhth immage size on bottom with white background
          FutureBuilder<String>(
            future: AssetUtils().getFileSize(asset),
            builder: (context, snapshot) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      snapshot.data ?? '',
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildRemainingCountBox(int remainingCount) {
  return Container(
    width: 70,
    height: 70,
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      color: Colors.grey.shade100,
    ),
    child: Center(
      child: Text(
        '+$remainingCount',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    ),
  );
}
