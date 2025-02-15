<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreChallengeStateRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        $user = $this->user();

        if ($user === null) {
            return false;
        }

        return $user->tokenCan('create:challengeStates');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'user_id' => ['required', 'uuid', 'exists:users,id'],
            'challenge_id' => ['required', 'string', 'max:255'],
            'step' => ['required', 'integer'],
            'shuffleSource' => ['nullable', 'integer'],
            'shuffleTargets' => ['nullable', 'string'],
            'otherShuffleTargets' => ['nullable', 'string'],
            'stringInputHint' => ['nullable', 'string'],
            'userStatus' => ['required', 'string'],
        ];
    }
}
