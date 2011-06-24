package com.li.minimole.core.utils
{
import flash.display.BitmapData;
import flash.display.BitmapData;
import flash.geom.Matrix;

public class TextureUtils
{
    public function TextureUtils()
    {
    }

    public static function ensurePowerOf2(bmd:BitmapData):BitmapData
    {
        var lowerWidth:uint = nearestInferiorPowerOf2(bmd.width);
        var lowerHeight:uint = nearestInferiorPowerOf2(bmd.height);

        var adjustedBmd:BitmapData = new BitmapData(lowerWidth, lowerHeight, false, 0);
        adjustedBmd.draw(bmd);

        return adjustedBmd;
    }

    public static function nearestInferiorPowerOf2(value:uint):uint
    {
        var result:uint = 0;
        var power:uint = 0;

        while(result <= value)
        {
            power++;
            result = Math.pow(2, power);
        }

        power--;
        result = Math.pow(2, power);

        return result;
    }

    public static function flipBmd(bmd:BitmapData, flipX:Boolean = true, flipY:Boolean = false):BitmapData
    {
        var flipBmd:BitmapData = new BitmapData(bmd.width, bmd.height, false, 0xFF0000);
        var matrix:Matrix = new Matrix();
        matrix.scale(flipX ? -1 : 1, flipY ? -1 : 1);
        matrix.translate(flipX ? bmd.width : 0, flipY ? bmd.height : 0);
        flipBmd.draw(bmd, matrix);
        return flipBmd;
    }
}
}
