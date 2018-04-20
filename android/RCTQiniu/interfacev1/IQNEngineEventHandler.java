package com.learnta.qiniu.interfacev1;

/**
 * IQNEngineEventHandler
 *
 * @author learnta
 * @version 1.0
 * @createDate 2018/4/20
 * @lastUpdate 2018/4/20
 */
public interface IQNEngineEventHandler {
    void onProgress(final String code, final String msg, final String percent);

    void onComplete(final String code, final String msg);

    void onError(final String code, final String msg);
}
