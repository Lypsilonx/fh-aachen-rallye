<?php

namespace App\Http\Requests\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdateChallengeStepRequest extends FormRequest
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

        return $user->tokenCan('update:challengeSteps');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        $method = $this->method();

        $rules = [
            'challenge_id' => ['required', 'uuid', 'exists:challenges,id'],
            'index' => ['required', 'integer'],
            'type' => ['required', 'string', 'max:255'],
            'text' => ['required', 'string'],
            'next' => ['integer', 'nullable'],
            'isLast' => ['required', 'boolean'],
        ];

        if ($this->input('type') === 'options') {
            $rules['options'] = ['required', 'string'];
        }

        if ($this->input('type') === 'stringInput' || $this->input('type') === 'scan') {
            $rules['correctAnswer'] = ['required', 'string'];
        }

        if ($this->input('type') === 'stringInput') {
            $rules['indexOnIncorrect'] = ['required', 'integer'];
        }

        if ($method === 'PUT') {
            return $rules;
        } else {
            foreach ($rules as $key => $value) {
                $rules[$key] = ['sometimes', ...$value];
            }
            return $rules;
        }
    }
}
