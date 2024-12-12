<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateChallengeRequest extends FormRequest
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

        return $user->tokenCan('update:challenges');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $method = $this->method();

        if ($method === 'PUT') {
            return [
                'challenge_id' => ['required', 'string', 'max:255'],
                'title' => ['required', 'string', 'max:255'],
                'language' => ['required', 'string', 'max:2', 'min:2'],
                'difficulty' => ['required', 'integer', 'min:0', 'max:5'],
                'points' => ['required', 'integer', 'min:0'],
                'category' => ['required', 'string', 'max:255'],
                'descriptionStart' => ['required', 'string'],
                'descriptionEnd' => ['required', 'string'],
                'image' => ['string', 'nullable'],
            ];
        } else {
            return [
                'challenge_id' => ['sometimes', 'required', 'string', 'max:255'],
                'title' => ['sometimes', 'required', 'string', 'max:255'],
                'language' => ['sometimes', 'required', 'string', 'max:2', 'min:2'],
                'difficulty' => ['sometimes', 'required', 'integer', 'min:0', 'max:5'],
                'points' => ['sometimes', 'required', 'integer', 'min:0'],
                'category' => ['sometimes', 'required', 'string', 'max:255'],
                'descriptionStart' => ['sometimes', 'required', 'string'],
                'descriptionEnd' => ['sometimes', 'required', 'string'],
                'image' => ['sometimes', 'string', 'nullable'],
            ];
        }
    }
}
