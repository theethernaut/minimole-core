package com.li.minimole.core.utils
{
public class VectorUtils
{
    public static function multiply4(a:Vector.<Number>, b:Vector.<Number>):Vector.<Number>
    {
        return Vector.<Number>([a[0]*b[0], a[1]*b[1], a[2]*b[2], a[3]*b[3]]);
    }
}
}
