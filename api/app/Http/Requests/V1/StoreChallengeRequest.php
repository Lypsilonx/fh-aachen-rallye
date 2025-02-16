<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreChallengeRequest extends FormRequest
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

        return $user->tokenCan('create:challenges');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'challenge_id' => ['required', 'string', 'max:255'],
            'title' => ['required', 'string', 'max:255'],
            'language' => ['required', 'string', 'max:2', 'min:2'],
            'difficulty' => ['required', 'integer', 'min:0', 'max:5'],
            'tags' => ['string', 'nullable'],
            'duration' => ['required', 'integer', 'min:0'],
            'points' => ['required', 'integer', 'min:0'],
            'category' => ['required', 'string', 'max:255'],
            'descriptionStart' => ['required', 'string'],
            'descriptionEnd' => ['required', 'string'],
            'image' => ['string', 'nullable'],
        ];
    }
}
