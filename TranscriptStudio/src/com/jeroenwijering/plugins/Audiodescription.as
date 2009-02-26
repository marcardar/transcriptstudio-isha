/**
* Plugin for playing closed captions and a closed audiodescription with a video.
**/
package com.jeroenwijering.plugins {


import com.jeroenwijering.events.*;

import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.*;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.text.*;


public class Audiodescription extends MovieClip implements PluginInterface {


	/** List with configuration settings. **/
	public var config:Object = {
		file:undefined,
		mute:false,
		volume:90
	}
	/** Reference to the MVC view. **/
	private var view:AbstractView;
	/** Reference to the icon. **/
	private var icon:MovieClip;
	/** sound object to be instantiated. **/
	private var sound:Sound;
	/** Sound channel object. **/
	private var channel:SoundChannel;


	/** Constructor; not much going on. **/
	public function Audiodescription():void {};


	/** Initing the plugin. **/
	public function initializePlugin(vie:AbstractView):void {
		view = vie;
		view.addControllerListener(ControllerEvent.ITEM,itemHandler);
		view.addModelListener(ModelEvent.TIME,timeHandler);
		view.addModelListener(ModelEvent.STATE,stateHandler);
		drawButton();
		mute(config['mute']);
	};


	/** Check for captions with a new item. **/
	private function itemHandler(evt:ControllerEvent=null):void {
		var aud:String = view.playlist[view.config['item']]['audiodescription.file'];
		if(aud) { 
			config['audio'] = aud; 
		} else if(view.config['audio']) {
			config['file'] = view.config['audio'];
		}
		if(config['file']) {
			sound = new Sound(new URLRequest(config['file']));
			channel = sound.play();
			setVolume();
		}
	};


	/** Mute/unmute the audiodesc. **/
	public function mute(stt:Boolean):void {
		config['mute'] = stt;
		view.saveCookie('audiodescription.mute',config['mute']);
		setVolume();
		if(config['mute']) {
			icon.alpha = 0.3;
		} else { 
			icon.alpha = 1;
		}
	};


	/** Clicking the  hide button. **/
	private function clickHandler(evt:MouseEvent):void {
		mute(!config['mute']);
	};


	/** Set buttons in the controlbar **/
	private function drawButton():void {
		try {
			icon = new MovieClip();
			icon.graphics.beginFill(0x000000);
			icon.graphics.moveTo(1,0);
			icon.graphics.lineTo(1,7);
			icon.graphics.lineTo(3,7);
			icon.graphics.lineTo(3,4);
			icon.graphics.lineTo(4,4);
			icon.graphics.lineTo(4,7);
			icon.graphics.lineTo(6,7);
			icon.graphics.lineTo(6,0);
			icon.graphics.lineTo(3,0);
			icon.graphics.lineTo(3,1);
			icon.graphics.lineTo(4,1);
			icon.graphics.lineTo(4,3);
			icon.graphics.lineTo(3,3);
			icon.graphics.lineTo(3,0);
			icon.graphics.moveTo(7,0);
			icon.graphics.lineTo(7,7);
			icon.graphics.lineTo(11,7);
			icon.graphics.lineTo(11,6);
			icon.graphics.lineTo(12,6);
			icon.graphics.lineTo(12,1);
			icon.graphics.lineTo(11,1);
			icon.graphics.lineTo(11,0);
			icon.graphics.lineTo(9,0);
			icon.graphics.lineTo(9,1);
			icon.graphics.lineTo(10,1);
			icon.graphics.lineTo(10,6);
			icon.graphics.lineTo(9,6);
			icon.graphics.lineTo(9,0);
			icon.graphics.lineTo(7,0);
			icon.graphics.endFill();
			view.getPlugin('controlbar').addButton(icon,'audiodescription',clickHandler);
		} catch (err:Error) {}
	};


	/** Set the volume level. **/
	private function setVolume():void {
		var trf:SoundTransform = new SoundTransform(config['volume']/100);
		if(config['mute']) { trf.volume = 0; }
		if(channel) { channel.soundTransform = trf; }
	};


	/** The statehandler manages audio pauses. **/
	private function stateHandler(evt:ModelEvent) {
		switch(evt.data.newstate) {
			case ModelStates.PAUSED:
			case ModelStates.COMPLETED:
			case ModelStates.IDLE:
				if(channel) {
					channel.stop();
				}
				break;
			}
	};


	/** Check timing of the player to sync audio if needed. **/
	private function timeHandler(evt:ModelEvent):void {
		var pos:Number = evt.data.position;
		if(channel && view.config['state'] == ModelStates.PLAYING && Math.abs(pos-channel.position/1000) > 0.5) {
			channel.stop();
			channel = sound.play(pos*1000);
			setVolume();
		}
	};


};


}