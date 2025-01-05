<?php

use App\Http\Controllers\Api\V1\ChallengeController;
use App\Http\Controllers\Api\V1\ChallengeStepController;
use App\Http\Controllers\Api\V1\UserController;
use App\Http\Controllers\Api\V1\ChallengeStateController;
use App\Http\Controllers\Api\V1\TranslationController;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CacheController;
use App\Http\Controllers\Api\V1\GameController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// api/v1
Route::group(['prefix' => 'v1', 'namespace' => 'App\Http\Controllers\Api\V1'], function () {
    Route::post('auth/register', [AuthController::class, 'register']);
    Route::post('auth/login', [AuthController::class, 'login']);
    Route::apiResource('translations', TranslationController::class)->only(['index', 'show']);
    Route::post('pollCache', [CacheController::class, 'cachePollRequest']);
});
Route::group(['prefix' => 'v1', 'namespace' => 'App\Http\Controllers\Api\V1', 'middleware' => 'auth:sanctum'], function () {
    Route::apiResource('challenges', ChallengeController::class);
    Route::apiResource('challengeSteps', ChallengeStepController::class);
    Route::apiResource('users', UserController::class);
    Route::apiResource('challengeStates', ChallengeStateController::class);
    Route::apiResource('translations', TranslationController::class)->except(['index', 'show']);
    Route::post('game/unlock', [GameController::class, 'unlockRequest']);
    Route::post('game/setChallengeStatus', [GameController::class, 'setChallengeStatusRequest']);
});