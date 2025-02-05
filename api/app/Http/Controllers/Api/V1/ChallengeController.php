<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Requests\V1\StoreChallengeRequest;
use App\Http\Requests\V1\UpdateChallengeRequest;
use App\Models\Challenge;
use App\Models\ChallengeState;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\ChallengeResource;
use App\Http\Resources\V1\ChallengeCollection;
use Illuminate\Http\Request;

class ChallengeController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        if (!auth()->user()->tokenCan('read:challenges')) {
            abort(403, 'Unauthorized action.');
        }

        $includeSteps = $request->query('includeSteps', false);

        if ($includeSteps) {
            return new ChallengeCollection(Challenge::with('steps')->paginate());
        }

        return new ChallengeCollection(Challenge::paginate());
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreChallengeRequest $request)
    {
        $challenge = Challenge::create($request->all());

        if ($request->has('steps')) {
            $steps = $request->input('steps');

            ChallengeController::storeSteps($challenge, $steps);
        }

        $challenge->load('steps');

        return new ChallengeResource($challenge);
    }

    public static function storeSteps($challenge, $steps)
    {
        if (is_string($steps)) {
            $steps = json_decode($steps, true);
        }

        $index = 0;
        foreach ($steps as $step) {
            $type = $step['type'] ?? 'say';
            $values = [
                'type' => $type,
                'text' => $step['text'],
                'next' => $step['next'] ?? null,
                'punishment' => $step['punishment'] ?? null,
                'alternatives' => $step['alternatives'] ?? null,
                'isLast' => $step['isLast'] ?? false,
            ];

            if ($type === 'options') {
                $values['options'] = $step['options'];
            }

            if ($type === 'stringInput' || $type === 'scan') {
                $values['correctAnswer'] = $step['correctAnswer'];
            }

            if ($type === 'stringInput') {
                $values['indexOnIncorrect'] = $step['indexOnIncorrect'];
                $values['hintCost'] = $step['hintCost'] ?? 10;
            }

            $challenge->steps()->updateOrCreate(
                [
                    'challenge_id' => $challenge->id,
                    'index' => $step['index'] ?? $index,
                ],
                $values
            );

            $index++;
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Challenge $challenge)
    {
        if (!auth()->user()->tokenCan('read:challenges')) {
            abort(403, 'Unauthorized action.');
        }

        if (!auth()->user()->tokenCan('read:challenges:locked')) {
            // check if challenge_states contains a record with the current user and the challenge
            if ($challenge->lock_id && ChallengeState::where('user_id', auth()->id())->where('challenge_id', $challenge->challenge_id)->doesntExist()) {
                // act as if the challenge doesn't exist
                abort(404, 'Challenge not found.');
            }
        }

        $includeSteps = request()->query('includeSteps', false);

        if ($includeSteps) {
            return new ChallengeResource($challenge->loadMissing('steps'));
        }

        return new ChallengeResource($challenge);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Challenge $challenge)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateChallengeRequest $request, Challenge $challenge)
    {
        $challenge->update($request->all());

        if ($request->has('steps')) {
            $steps = $request->input('steps');

            ChallengeController::storeSteps($challenge, $steps);
        }

        $challenge->load('steps');

        return new ChallengeResource($challenge);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Challenge $challenge)
    {
        if (!auth()->user()->tokenCan('delete:challenges')) {
            abort(403, 'Unauthorized action.');
        }

        $challenge->delete();

        return response()->json([
            'status' => true,
            'message' => 'Challenge deleted successfully'
        ]);
    }
}
