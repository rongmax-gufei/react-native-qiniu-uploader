package com.learnta.qiniu.utils;

import android.os.Environment;

/**
 * FileUtil
 *
 * @author gufei
 * @version 1.0
 * @createDate 2018-04-20
 * @lastUpdate 2018-04-20
 */
public class FileUtil {

    private String TAG = this.getClass().getSimpleName();

    private static final String PACKAGE_NAME = "cn.learnta.qiniu/";
    private static final String DATA_DIRECTORY = "/data/" + PACKAGE_NAME;
    private static final String SDCARD_DIRECTORY = "/Android" + DATA_DIRECTORY;

    public static final int PATH_SDCARD = 0;
    public static final int PATH_DATA = 1;

    public static String getWorkFolder() {
        boolean sdCardExist = Environment.getExternalStorageState().equals(
                Environment.MEDIA_MOUNTED);
        if (sdCardExist) {
            return getWorkFolder(PATH_SDCARD);
        } else {
            return getWorkFolder(PATH_DATA);
        }
    }

    public static String getWorkFolder(int path) {
        if (PATH_DATA == path) {
            return Environment.getDataDirectory() + DATA_DIRECTORY;
        } else {
            return Environment.getExternalStorageDirectory() + SDCARD_DIRECTORY;
        }
    }
}
