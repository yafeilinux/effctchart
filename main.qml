/******************************************************************************
    Effect Chart:  Special effects chart based on Qt and QML
    Copyright (C) 2018-2019 yafeilinux <www.qter.org | yafeilinux@163.com>
*   This file is part of effectchart
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.
    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY.  See the GNU Lesser General Public License
    for more details.
    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
******************************************************************************/

import QtQuick 2.9
import QtQuick.Window 2.2
import QtCharts 2.3
import QtQuick.XmlListModel 2.0
import QtGraphicalEffects 1.12

Window {
    visible: true
    width: 800
    height: 480
    property int currentIndex: -1
    color: "black"

    ChartView {
        id: chartView
        anchors.fill: parent
        antialiasing: true

        backgroundColor: "transparent"
        legend.visible: false

        // 曲线发生图片
        Image {
            id: img
            source: "circle.png"
            width: 100; height: 100
            x: -10; y: 230
            visible: true
            Behavior on rotation {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.InOutElastic;
                    easing.amplitude: 2.0;
                    easing.period: 1.5
                }
            }
        }

        // 显示数字的文本
        Text {
            id:txt
            width: 200; height: 20
            x: 350; y: 55
            font.pointSize: 20
            font.family: "Cambria"
            color: "#F8F8FF"
        }
    }

    // 解析XML数据
    XmlListModel {
        id: speedsXml
        source: "speed.xml"
        query: "/results/row"

        XmlRole { name: "speedTrap"; query: "speedTrap/string()" }
        XmlRole { name: "driver"; query: "driver/string()" }
        XmlRole { name: "speed"; query: "speed/string()" }

        onStatusChanged: {
            if (status == XmlListModel.Ready) {
                timer.start();
            }
        }
    }

    // 在定时器中动态添加数据
    Timer {
        id: timer
        interval: 800
        repeat: true
        triggeredOnStart: true
        running: false
        onTriggered: {
            currentIndex++;
            if (currentIndex < speedsXml.count) {
                var lineSeries = chartView.series(speedsXml.get(0).driver);
                // 第一次运行时创建曲线
                if (!lineSeries) {
                    lineSeries = chartView.createSeries(ChartView.SeriesTypeSpline,
                                                        speedsXml.get(0).driver);
                    chartView.axisY().min = 0;
                    chartView.axisY().max = 250;
                    chartView.axisY().tickCount = 6;
                    chartView.axisY().titleText = "speed (kph)";
                    chartView.axisX().titleText = "speed trap";
                    chartView.axisX().labelFormat = "%.0f";
                    lineSeries.color = "#87CEFA"
                    chartView.animationOptions = ChartView.SeriesAnimations

                    chartView.axisX().visible = false
                    chartView.axisY().visible = false
                }

                lineSeries.append(speedsXml.get(currentIndex).speedTrap,
                                  speedsXml.get(currentIndex).speed);

                txt.text = speedsXml.get(currentIndex).speed;
                img.rotation += 360

                if (speedsXml.get(currentIndex).speedTrap > 3) {
                    chartView.axisX().max =
                            Number(speedsXml.get(currentIndex).speedTrap)+1;
                } else {
                    chartView.axisX().max = 5;
                    chartView.axisX().min = 0;
                }
                chartView.axisX().tickCount = chartView.axisX().max
                        - chartView.axisX().min + 1;
            } else {
                timer.stop();
                chartView.animationOptions = ChartView.AllAnimations;
                chartView.axisX().min = 0;
                chartView.axisX().max = speedsXml.get(currentIndex - 1).speedTrap;
            }
        }
    }

    // 下面是对图表添加的图形效果
    Glow {
        id:glow
        anchors.fill: chartView
        radius: 18
        samples: 37
        color: "#87CEFA"
        source: chartView
    }

    RadialBlur {
        anchors.fill: chartView
        source: chartView
        angle: 360
        samples: 20
    }

    ZoomBlur {
        anchors.fill: chartView
        source: chartView
        length: 24
        samples: 20
    }

    // 下面是图表边框及其发光效果
    Image {
        id: border
        source: "border.png"
        anchors.fill: parent
    }

    Glow {
        anchors.fill: border
        radius: 18
        samples: 37
        color: "#87CEFA"
        source: border
    }
}




