<?php

namespace App\Http\Controllers\Api\V1;

use App\Models\User;
use Hash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;

class AuthController extends Controller
{
    public $adminTokenCapabilities = ['create:challenges', 'read:challenges', 'update:challenges', 'delete:challenges', 'create:challengeSteps', 'read:challengeSteps', 'update:challengeSteps', 'delete:challengeSteps'];

    public function register(Request $request)
    {

        try {
            $validatedUser = Validator::make(
                $request->all(),
                [
                    'username' => 'required|unique:users,username',
                    'password' => 'required'
                ],
            );

            if ($validatedUser->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation failed',
                    'errors' => $validatedUser->errors()
                ], 401);
            }

            $user = User::create([
                'username' => $request->username,
                'password' => Hash::make($request->password)
            ]);

            return response()->json([
                'status' => true,
                'message' => 'User created successfully',
                'userId' => $user->id,
                'token' => $user->createToken('auth_token', $this->adminTokenCapabilities)->plainTextToken
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function login(Request $request)
    {
        try {
            $validatedUser = Validator::make(
                $request->all(),
                [
                    'username' => 'required',
                    'password' => 'required'
                ],
            );

            if ($validatedUser->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation failed',
                    'errors' => $validatedUser->errors()
                ], 401);
            }

            if (!Auth::attempt($request->only('username', 'password'))) {
                return response()->json([
                    'status' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            $user = User::where('username', $request->username)->first();

            if (!$user || !Hash::check($request->password, $user->password)) {
                return response()->json([
                    'status' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }

            return response()->json([
                'status' => true,
                'message' => 'User logged in successfully',
                'userId' => $user->id,
                'token' => $user->createToken('auth_token', $this->adminTokenCapabilities)->plainTextToken
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
