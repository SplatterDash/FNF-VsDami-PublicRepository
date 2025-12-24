lastConductorPos = 0

function onSongStart()
	oppX0 = defaultOpponentStrumX0
	oppX1 = defaultOpponentStrumX1
	oppX2 = defaultOpponentStrumX2
	oppX3 = defaultOpponentStrumX3
	oppY0 = defaultOpponentStrumY0
	oppY1 = defaultOpponentStrumY1
	oppY2 = defaultOpponentStrumY2
	oppY3 = defaultOpponentStrumY3

	bfX0 = defaultPlayerStrumX0
	bfX1 = defaultPlayerStrumX1
	bfX2 = defaultPlayerStrumX2
	bfX3 = defaultPlayerStrumX3
	if not middlescroll then
		middle0 = defaultPlayerStrumX0 - 320
		middle1 = defaultPlayerStrumX1 - 320
		middle2 = defaultPlayerStrumX2 - 320
		middle3 = defaultPlayerStrumX3 - 320
	else
		middle0 = defaultPlayerStrumX0
		middle1 = defaultPlayerStrumX1
		middle2 = defaultPlayerStrumX2
		middle3 = defaultPlayerStrumX3
	end
	center = (middle1 + middle2) / 2

	oppA = getPropertyFromGroup('strumLineNotes', 0, 'alpha')

	if not downscroll then
		vertMovement = 1
		vertDirection = 0
	else
		vertMovement = -1
		vertDirection = 180
	end
end

function onUpdate(elapsed)
	time = 127666.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenX('Center0', 0, middle0, 0.392, 'linear')
			noteTweenX('Center1', 1, middle1, 0.392, 'linear')
			noteTweenX('Center2', 2, middle2, 0.392, 'linear')
			noteTweenX('Center3', 3, middle3, 0.392, 'linear')
			noteTweenX('Center4', 4, middle0, 0.392, 'linear')
			noteTweenX('Center5', 5, middle1, 0.392, 'linear')
			noteTweenX('Center6', 6, middle2, 0.392, 'linear')
			noteTweenX('Center7', 7, middle3, 0.392, 'linear')
			noteTweenY('MoveDown0', 0, oppY0 + (vertMovement * 520), 0.392, 'linear')
			noteTweenY('MoveDown1', 1, oppY1 + (vertMovement * 520), 0.392, 'linear')
			noteTweenY('MoveDown2', 2, oppY2 + (vertMovement * 520), 0.392, 'linear')
			noteTweenY('MoveDown3', 3, oppY3 + (vertMovement * 520), 0.392, 'linear')
			if not middlescroll then
				noteTweenAlpha('Ghostly0', 0, oppA * 0.3, 0.392, 'linear')
				noteTweenAlpha('Ghostly1', 1, oppA * 0.3, 0.392, 'linear')
				noteTweenAlpha('Ghostly2', 2, oppA * 0.3, 0.392, 'linear')
				noteTweenAlpha('Ghostly3', 3, oppA * 0.3, 0.392, 'linear')
			end
			noteTweenAngle('Rotate0', 0, (vertMovement * 1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate1', 1, (vertMovement * 1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate2', 2, (vertMovement * 1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate3', 3, (vertMovement * 1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate4', 4, (vertMovement * -1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate5', 5, (vertMovement * -1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate6', 6, (vertMovement * -1080), 0.392, 'quintIn')
			noteTweenAngle('Rotate7', 7, (vertMovement * -1080), 0.392, 'quintIn')
			if middlescroll then
				noteTweenDirection('Point0', 0, -90, 0.392, 'linear')
				noteTweenDirection('Point1', 1, -90, 0.392, 'linear')
			else
				noteTweenDirection('Point0', 0, 270, 0.392, 'linear')
				noteTweenDirection('Point1', 1, 270, 0.392, 'linear')
			end
			noteTweenDirection('Point2', 2, 270, 0.392, 'linear')
			noteTweenDirection('Point3', 3, 270, 0.392, 'linear')
		end
	end
	time = 137900
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Disappear0', 0, 0, 0.392, 'linear')
			noteTweenAlpha('Disappear1', 1, 0, 0.392, 'linear')
			noteTweenAlpha('Disappear2', 2, 0, 0.392, 'linear')
			noteTweenAlpha('Disappear3', 3, 0, 0.392, 'linear')
		end
	end
	time = 138333.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenX('Return0', 0, oppX0, 0.392, 'linear')
			noteTweenX('Return1', 1, oppX1, 0.392, 'linear')
			noteTweenX('Return2', 2, oppX2, 0.392, 'linear')
			noteTweenX('Return3', 3, oppX3, 0.392, 'linear')
			noteTweenX('Aethos4', 4, middle0 - 75, 0.392, 'linear')
			noteTweenX('Aethos5', 5, middle1 - 25, 0.392, 'linear')
			noteTweenX('Aethos6', 6, middle2 + 25, 0.392, 'linear')
			noteTweenX('Aethos7', 7, middle3 + 75, 0.392, 'linear')
			noteTweenY('MoveDown0', 0, oppY0, 0.392, 'linear')
			noteTweenY('MoveDown1', 1, oppY1, 0.392, 'linear')
			noteTweenY('MoveDown2', 2, oppY2, 0.392, 'linear')
			noteTweenY('MoveDown3', 3, oppY3, 0.392, 'linear')
			noteTweenAngle('Rotate0', 0, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate1', 1, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate2', 2, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate3', 3, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate4', 4, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate5', 5, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate6', 6, 0, 0.392, 'quintIn')
			noteTweenAngle('Rotate7', 7, 0, 0.392, 'quintIn')
			noteTweenDirection('Point0', 0, 90, 0.0000001, 'linear')
			noteTweenDirection('Point1', 1, 90, 0.0000001, 'linear')
			noteTweenDirection('Point2', 2, 90, 0.0000001, 'linear')
			noteTweenDirection('Point3', 3, 90, 0.0000001, 'linear')
		end
	end
	time = 149916.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenAlpha('DisappearHUD', 'camHUD', 0, 0.725, 'linear')
		end
	end
	time = 155000
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Reappear0', 0, oppA, 0.0000001, 'linear')
			noteTweenAlpha('Reappear1', 1, oppA, 0.0000001, 'linear')
			noteTweenAlpha('Reappear2', 2, oppA, 0.0000001, 'linear')
			noteTweenAlpha('Reappear3', 3, oppA, 0.0000001, 'linear')
			noteTweenX('Return4', 4, bfX0, 0.0000001, 'linear')
			noteTweenX('Return5', 5, bfX1, 0.0000001, 'linear')
			noteTweenX('Return6', 6, bfX2, 0.0000001, 'linear')
			noteTweenX('Return7', 7, bfX3, 0.0000001, 'linear')
		end
	end
	time = 158666.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenAlpha('ReappearHUD', 'camHUD', 1, 1.058, 'linear')
		end
	end
	time = 211166.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate0', 0, (vertMovement * 270), 0.0000001, 'linear')
			noteTweenX('MoveNote1', 1, oppX0, 0.0000001, 'linear')
		end
	end
	time = 211187.5
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, (vertMovement * 90), 0.0000001, 'linear')
			noteTweenX('MoveNote1', 1, oppX0, 0.0000001, 'linear')
		end
	end
	time = 211208.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate2', 2, (vertMovement * 180), 0.0000001, 'linear')
			noteTweenX('MoveNote1', 1, oppX2, 0.0000001, 'linear')
		end
	end
	time = 211229.166666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenX('MoveNote1', 1, oppX1, 0.0000001, 'linear')
		end
	end
	time = 212166.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, (vertMovement * -15), 0.225, 'quintIn')
		end
	end
	time = 212283.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate1', 1, (vertMovement * -15), 0.05, 'quintIn')
		end
	end
	time = 212416.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate1', 1, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate3', 3, 0, 0.142, 'quintOut')
		end
	end
	time = 212500
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate2', 2, (vertMovement * -15), 0.225, 'quintIn')
		end
	end
	time = 212616.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, (vertMovement * -15), 0.05, 'quintIn')
			noteTweenAngle('Rotate1', 1, (vertMovement * -15), 0.05, 'quintIn')
		end
	end
	time = 212750
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate2', 2, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate1', 1, 0, 0.142, 'quintOut')
		end
	end
	time = 212833.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate0', 0, 0, 0.225, 'quintIn')
		end
	end
	time = 212950
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, (vertMovement * -15), 0.05, 'quintIn')
			noteTweenAngle('Rotate2', 2, (vertMovement * -15), 0.05, 'quintIn')
			noteTweenAngle('Rotate1', 1, (vertMovement * -15), 0.05, 'quintIn')
		end
	end
	time = 213083.333333333
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAngle('Rotate3', 3, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate2', 2, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate1', 1, 0, 0.142, 'quintOut')
			noteTweenAngle('Rotate0', 0, 0, 0.142, 'quintOut')
		end
	end
	time = 213833.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Disappear0', 0, 0, 0.558, 'linear')
		end
	end
	time = 214333.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Disappear1', 1, 0, 0.558, 'linear')
		end
	end
	time = 214833.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Disappear3', 3, 0, 0.792, 'linear')
		end
	end
	time = 215600
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenX('MoveNote0', 0, oppX0 - 50, 0.0000001, 'linear')
			noteTweenY('MoveNote1', 1, oppY1 + 50, 0.0000001, 'linear')
			noteTweenX('MoveNote3', 3, oppX3 + 50, 0.0000001, 'linear')
		end
	end
	time = 215766.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenAlpha('Reappear0', 0, oppA, 0.0000001, 'linear')
			noteTweenAlpha('Reappear1', 1, oppA, 0.0000001, 'linear')
			noteTweenAlpha('Reappear3', 3, oppA, 0.0000001, 'linear')
			noteTweenX('MoveNote0', 0, oppX0, 0.392, 'elasticInOut')
			noteTweenY('MoveNote1', 1, oppY1, 0.392, 'elasticInOut')
			noteTweenX('MoveNote3', 3, oppX3, 0.392, 'elasticInOut')
		end
	end
	time = 216666.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1 + 100, 0.0000001, 'linear')
		end
	end
	time = 216833.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1 + 200, 0.0000001, 'linear')
		end
	end
	time = 217000
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1 + 150, 0.0000001, 'linear')
		end
	end
	time = 217083.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1 + 100, 0.0000001, 'linear')
		end
	end
	time = 217166.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1 + 50, 0.0000001, 'linear')
		end
	end
	time = 217250
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenY('MoveNote1', 1, oppY1, 0.0000001, 'linear')
		end
	end
	time = 217866.666666667
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenX('noteSize2X', 'strumLineNotes.members[2].scale', 1.15, 0.392, 'elasticInOut')
			doTweenY('noteSize2Y', 'strumLineNotes.members[2].scale', 1.15, 0.392, 'elasticInOut')
		end
	end
	time = 218000
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenZoom('zoomOut', 'camGame', 0.65, 0.725, 'quintOut')
			noteTweenAlpha('Disappear0', 0, 0, 0.1, 'linear')
			noteTweenAlpha('Disappear1', 1, 0, 0.1, 'linear')
			noteTweenAngle('speen2', 2, (vertMovement * 1080), 0.725, 'quintIn')
			noteTweenAlpha('Disappear3', 3, 0, 0.1, 'linear')
		end
	end
	time = 218433.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenX('noteSize2X', 'strumLineNotes.members[2].scale', 0.725, 0.392, 'elasticInOut')
			doTweenY('noteSize2Y', 'strumLineNotes.members[2].scale', 0.725, 0.392, 'elasticInOut')
			noteTweenAlpha('Reappear0', 0, oppA, 1.108, 'quintOut')
			noteTweenAlpha('Reappear1', 1, oppA, 1.108, 'quintOut')
			noteTweenAlpha('Reappear3', 3, oppA, 1.108, 'quintOut')
		end
	end
	time = 242000
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			noteTweenX('MoveNote0', 0, middle0, 0.725, 'quintIn')
			noteTweenX('MoveNote1', 1, middle1, 0.725, 'quintIn')
			noteTweenX('MoveNote2', 2, middle2, 0.725, 'quintIn')
			noteTweenX('MoveNote3', 3, middle3, 0.725, 'quintIn')
			noteTweenX('MoveNote4', 4, middle0, 0.725, 'quintIn')
			noteTweenX('MoveNote5', 5, middle1, 0.725, 'quintIn')
			noteTweenX('MoveNote6', 6, middle2, 0.725, 'quintIn')
			noteTweenX('MoveNote7', 7, middle3, 0.725, 'quintIn')
		end
	end
	time = 245333.333333334
	if time <= getSongPosition() + 3 then
		if time >= lastconductorpos then
			doTweenAlpha('DisappearHUD', 'camHUD', 0, 2.725, 'linear')
		end
	end
	lastconductorpos = getSongPosition()
end

--generated by methewhenmethes modchart editor